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

  def query(kernel)
    @from = lambda{|from|
      lambda{|where|
        lambda{|select|
          "SELECT " + select +
          "  FROM " + from + 
          " WHERE " + where 
        }
      }
    }

    @table = self.params["table"]

    @kernel = kernel

    @kernel_with_where = @kernel.
      call(
           "true"
           )

    @kernel_with_select = @kernel_with_where.
      call(
           "*"
           )

    @sql = @kernel_with_select
    
    @count_sql = "SELECT count(*) FROM (" + @kernel_with_where.call("1") + ") AS count"
    @count = ActiveRecord::Base.connection.execute(@count_sql)[0]['count']


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

    @table = self.params["table"]

    if (!@table) 
#      @table = "business_units"
#      self.params['table'] = @table
    else

      if (!self.params["join1"])
        #      self.params["join1"] = "people"
      end
      
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
      
      if (self.params["join1"] != '')
        @kernel = @from.
          call(
               @table + " AS table_a " + 
               self.params["joindir"] + "  JOIN " +
               self.params["join1"] + " AS table_b " + 
               " ON " + self.params["jc1"] + " = " + self.params["jc2"]
               )
      else
        @kernel = @from.
          call(
               @table
               )
      end
      
      @kernel_with_where = @kernel.
        call(
             "true"
             )
      
      @kernel_with_select = @kernel_with_where.
        call(
             "*"
             )
      
      @sql = @kernel_with_select
      
      @count_sql = "SELECT count(*) FROM (" + @kernel_with_where.call("1") + ") AS count"
      @count = ActiveRecord::Base.connection.execute(@count_sql)[0]['count']
    end

    @xml = ""

    xml = Builder::XmlMarkup.new(:target => @xml, :indent => 2 )
    xml.view {

      xml.metadata {

        xml.joindirs {
          xml.joindir(:name => "LEFT")
          xml.joindir(:name => "RIGHT")
          xml.joindir(:name => "INNER")
        }

        tables_query_kernel = @from.call("information_schema.tables").call("(table_schema != 'information_schema') AND (table_schema != 'pg_catalog')")
        tables_sql = tables_query_kernel.call("table_schema AS schema,table_name AS name") + " ORDER BY table_name"

        tables_count_sql = "SELECT count(*) FROM (" + tables_query_kernel.call("1") + ") AS count"
        tables_count = ActiveRecord::Base.connection.execute(tables_count_sql)[0]['count']

        xml.tables(:sql => tables_sql,:count => tables_count) {
          @results = ActiveRecord::Base.connection.execute(tables_sql)
          @results.each do |r| 
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

      xml.params(self.params)

      if @sql
        xml.rows(:sql => @sql,:count => @count) {
          @results = ActiveRecord::Base.connection.execute(@sql)
          @results.each do |r| 
            xml.row(r)
          end
        }
      end
    }

    if self.params["output"] == "xml"
      render :xml => @xml
    else
      xslt = XML::XSLT.new()
      xslt.xml = @xml
 
      xslt.parameters = {
        "table" => @table
      }
      
      xslt.xsl = File.read("public/stylesheets/sql_view.xsl")
      @out = xslt.serve()

      render :xml => @out
    end
  end

end
