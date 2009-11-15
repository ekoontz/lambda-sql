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

    @from = lambda{|from|
      lambda{|where|
        lambda{|select|
          "SELECT " + select +
          "  FROM " + from + 
          " WHERE " + where
        }
      }
    }

    def join(table_a,table_b,join_type,condition1,condition2)
      retval = table_a.to_s
      if join_type
        retval = retval + " " + join_type + " JOIN " + table_b + " ON " + condition1 + " = " + condition2
      end
      return retval
    end

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
    
    kernel = 
      @from.call(
                 join(@table,
                      self.params["join1"],self.params["joindir"],self.params["jc1"],self.params["jc2"])
                 )

    # </define the kernel function from the user's desired params.>

    # <use the kernel to 
    #  count the number of rows that would be returned this query.
    # without any LIMIT or OFFSET.>
    @count_sql = "SELECT count(*) FROM (" + 
      kernel.call("true").call("1")  + ") AS count"
    @count = ActiveRecord::Base.connection.execute(@count_sql)[0]['count']
    # </count the number of rows..>

    @offset = self.params["offset"].to_i

    # <paging>
    if (self.params["page"] == "beginning") 
      @offset = 0
    end

    if (self.params["page"] == "back") 
      @offset = [(@offset - 10),0].max
    end

    if (self.params["page"] == "forward") 
      @offset = [@offset + 10,@count.to_i - (@count.to_i % 10)].min
    end

    if (self.params["page"] == "end") 
      @offset = [0,@count.to_i - ( @count.to_i % 10 )].max
    end
    # </paging>

    @limit = 10

    # compose the actual SQL that will be sent to the database:
    @sql = kernel.call("true").call("*") + " OFFSET " + @offset.to_s + " LIMIT " + @limit.to_s

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
