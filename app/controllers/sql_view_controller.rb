require 'xml/xslt'

class SqlViewController < ApplicationController

 before_filter :set_content_type
 
  def set_content_type
    @headers = {}
    if self.params["format"] == "xml"
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

    if (self.params["join1"] != '')
      @kernel = @from.
        call(
             @table +  " INNER JOIN " + self.params["join1"] + " ON true "
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
    
    @xml = ""
    xml = Builder::XmlMarkup.new(:target => @xml, :indent => 2 )
    xml.view {

      xml.metadata {
        tables_query_kernel = @from.call("pg_tables").call("schemaname='public'")
        tables_sql = tables_query_kernel.call("*")
        tables_count_sql = "SELECT count(*) FROM (" + tables_query_kernel.call("1") + ") AS count"
        tables_count = ActiveRecord::Base.connection.execute(tables_count_sql)[0]['count']

        xml.tables(:sql => tables_sql,:count => tables_count) {
          @results = ActiveRecord::Base.connection.execute(tables_sql)
          @results.each do |r| 
            xml.table(r)
          end
        }
      }

      xml.params(self.params)

      xml.rows(:sql => @sql,:count => @count) {
        @results = ActiveRecord::Base.connection.execute(@sql)
        @results.each do |r| 
          xml.row(r)
        end
      }
    }

    if self.params["format"] == "xml"
      render :xml => @xml
    else
      xslt = XML::XSLT.new()
      xslt.xml = @xml
 
      xslt.parameters = {
      }
      
      xslt.xsl = File.read("public/stylesheets/sql_view.xsl")
      @out = xslt.serve()

      render :xml => @out
    end
  end

end
