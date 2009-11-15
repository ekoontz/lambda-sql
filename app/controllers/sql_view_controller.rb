require 'xml/xslt'

class SqlViewController < ApplicationController

 before_filter :set_content_type
 
  def set_content_type
    @headers = {}
    if self.params["output"] == "xml"
      @headers["Content-Type"] = "text/xml; charset=utf-8"
    end
  end

  def create
  end

  def read
  end

  def update
  end

  def delete
  end

  def index
    
    if (!self.params["joindir"])
      self.params["joindir"] = ""
    end
    
    if (!self.params["jc1"])
      self.params["jc1"] = "TRUE"
    end
    
    if (!self.params["jc2"])
      self.params["jc2"] = "TRUE"
    end
    
    if (!self.params["join1"])
      self.params["join1"] = ""
    end

    @from = lambda{|from|
      lambda{|where|
        lambda{|select|
          "SELECT " + select +
          "  FROM " + from + 
          " WHERE " + where 
        }
      }
    }

    # <get database metadata>
    tables_query_kernel = @from.call("information_schema.tables").call("(table_schema != 'information_schema') AND (table_schema != 'pg_catalog')")
    tables_sql = tables_query_kernel.call("table_schema AS schema,table_name AS name") + " ORDER BY table_name"
    
    tables_count_sql = "SELECT count(*) FROM (" + tables_query_kernel.call("1") + ") AS count"

    tables_count = ActiveRecord::Base.connection.execute(tables_count_sql)[0]['count']
    @results_dbinfo = ActiveRecord::Base.connection.execute(tables_sql)
    # </get database metadata>

    # <define the kernel from the user's desired params.>
    #  (we assume that the "table" param is defined to real table by the
    #  time this function (the sql_view.index controller) is called.)

    if (self.params["table"])
      @table = self.params["table"]
    else
      # if no table given, use first table from list of database tables.
      @table = @results_dbinfo[0]['name']
    end
    
    if (self.params["join1"] != '')
      kernel = @from.
        call(
             @table + " AS table_a " + 
             self.params["joindir"] + "  JOIN " +
             self.params["join1"] + " AS table_b " + 
             " ON " + self.params["jc1"] + " = " + self.params["jc2"]
             )
    else
      kernel = @from.call(@table)
    end
    # </define the kernel function from the user's desired params.>

    # <use the kernel to 
    #  count the number of rows that would be returned this query (@sql) 
    # without any LIMIT or OFFSET.>
    @count_sql = "SELECT count(*) FROM (" + 
      kernel.call("true").call("1")  + ") AS count"
    @count = ActiveRecord::Base.connection.execute(@count_sql)[0]['count']
    # </count the number of rows..>

    # compose the actual SQL that will be sent to the database:
    if (self.params["offset"]) 
      @offset = self.params["offset"]
    end

    if (self.params["page"] == "back") 
      @offset = [(@offset.to_i - 10),0].max
    end

    if (self.params["page"] == "beginning") 
      @offset = 0
    end

    if (self.params["page"] == "forward") 
      @offset = [@offset.to_i + 10,@count.to_i - (@count.to_i % 10)].min
    end

    if (self.params["page"] == "end") 
      @offset = [0,@count.to_i - ( @count.to_i % 10 )].max
    end

    if (@offset)
    else
      @offset = 0
    end

    @offset = @offset.to_s

    @limit = "10"

    @sql = kernel.call("true").call("*") + " OFFSET " + @offset + " LIMIT " + @limit

    # DO THE ACTUAL QUERY.
    @results = ActiveRecord::Base.connection.execute(@sql)

    # <build the xml output.>
    @xml = ""
    xml = Builder::XmlMarkup.new(:target => @xml, :indent => 2 )

    mytime = Time.now
    # fixme: add page load time (Time.now minus request_start_time)
    xml.view(:time => mytime)  {
      

      # <xml output part 1: actual payload: client query results>
      if @sql
        xml.rows(:sql => @sql,
                 :count => @count,
                 :offset => @offset,
                 :limit => @limit
                 ) {
          @results.each do |r| 
            xml.row(r)
          end
        }
      end

      # </xml output part 1: actual payload: client query results>


      # <xml output part 2: metadata about entire database.>
      xml.metadata {

        # <metadata about client request (self.params)>
        xml.params(self.params)

        xml.joindirs {
          xml.joindir(:name => "LEFT")
          xml.joindir(:name => "RIGHT")
          xml.joindir(:name => "INNER")
        }

        xml.tables(:sql => tables_sql,
                   :count => tables_count
                   ) {
          @results_dbinfo.each do |r| 
            xml.table(r)
          end
        }

        columns_query_kernel = @from.call("information_schema.columns").call("(table_schema != 'information_schema') AND (table_schema != 'pg_catalog')")
        columns_sql = columns_query_kernel.call("table_schema,table_name,column_name AS name,data_type") + " ORDER BY column_name"
        columns_count_sql = "SELECT count(*) FROM (" + columns_query_kernel.call("1") + ") AS count"
        columns_count = ActiveRecord::Base.connection.execute(columns_count_sql)[0]['count']

        xml.columns(:sql => columns_sql,:count => columns_count) {
          @results = ActiveRecord::Base.connection.execute(columns_sql)
          @results.each do |r| 
            xml.column(r)
          end
        }


      }

      # </xml output part 2: metadata about entire database.>



    }
    # </build the xml output.>


    if self.params["output"] == "xml"
      render :xml => @xml
    else
      xslt = XML::XSLT.new()
      xslt.xml = @xml
 
      if @table 
        xslt.parameters = {
          "table" => @table
        }
      end
      
      xslt.xsl = File.read("public/stylesheets/sql_view.xsl")
      @out = xslt.serve()

      render :xml => @out
    end
  end

end
