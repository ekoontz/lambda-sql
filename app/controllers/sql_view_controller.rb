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

    @where_new = lambda{|value|
      lambda{|table_alias|
        lambda{|column|
          table_alias + "." + column + " = '"+value+"'"
        }
      }
    }

    if (self.params["value"])
      value = self.params["value"]
    else
      value = "foo"
    end  

    if (self.params["column"])
      column = self.params["column"]
    else
      column = "foo_col"
    end  

    # <get database metadata>
    tables_query_kernel = @from.call("information_schema.tables").call("(table_schema != 'information_schema') AND (table_schema != 'pg_catalog')")
    tables_sql = tables_query_kernel.call("table_schema AS schema,table_name AS name") + " ORDER BY table_name"
    
    tables_count_sql = "SELECT count(*) FROM (" + tables_query_kernel.call("1") + ") AS count"

    tables_count = ActiveRecord::Base.connection.execute(tables_count_sql)[0]['count']
    @results_dbinfo = ActiveRecord::Base.connection.execute(tables_sql)
    # </get database metadata>

    if (self.params["table"])
      @table = self.params["table"]
    else
      # if no table given, use first table from list of database tables.
      @table = @results_dbinfo[0]['name']
    end

    if (self.params["table_alias"])
      @table_alias = self.params["table_alias"]
    else
      @table_alias = "table_a"
    end

    select3 = lambda{|select,table,joins|
      "SELECT " + select + " " +
      " FROM " + table + " " +
      joins
    }

    join = lambda{|type,table,c1,c2|
      type.upcase + " JOIN " + table + " ON " + c1 + " = " + c2
    }

    join3 = lambda{|select_cols|
      lambda{|table_a,alias_a,
        table_b,alias_b,
        table_c,alias_c|
        lambda{|jc_a1,jc_b1,jc_b2,jc_c2|
          select3.call(select_cols,
                      table_a + ' ' + alias_a,
                      join.call('inner',table_b+' '+alias_b,alias_a+'.'+jc_a1,alias_b+'.'+jc_b1) + ' ' +
                      join.call('inner',table_c+' '+alias_c,alias_c+'.'+jc_b2,alias_b+'.'+jc_c2))
        }
      }
    }
    
    @from_new_sql = join3.call(@table_alias+'.name AS station_a,b_station.name AS station_b').
      call('station',@table_alias,
           'adjacent','adj',
           'station','b_station').call('abbr','station_a','abbr','station_b')

    @count_sql = "SELECT count(*) FROM (" + 
      join3.call('1').
      call('station',@table_alias,
           'adjacent','adj',
           'station','b_station').call('abbr','station_a','abbr','station_b') + ") AS count"

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
    @sql = 
      join3.call(@table_alias+'.name AS station_a,b_station.name AS station_b').
      call('station',@table_alias,
           'adjacent','adj',
           'station','b_station').call('abbr','station_a','abbr','station_b') +
      " OFFSET " + @offset.to_s + " LIMIT " + @limit.to_s

    # DO THE ACTUAL QUERY.
    @results = ActiveRecord::Base.connection.execute(@sql)

    # <build the xml output.>
    @xml = ""
    xml = Builder::XmlMarkup.new(:target => @xml, :indent => 2 )

    from_new_sql = "(none)"
    from_new_html_string = "<h1>test</h1>"

    mytime = Time.now
    # fixme: add page load time (Time.now minus request_start_time)
    xml.view(:time => mytime)  {

      xml.new_sql(from_new_sql)

      # note that we use "<<" rather than "." because
      # from_new_html_string is itself xml that we want to 
      # incorporate inside the main xml document.
      xml << from_new_html_string

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
