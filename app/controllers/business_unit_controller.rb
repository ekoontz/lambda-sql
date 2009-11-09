require 'xml/xslt'

class BusinessUnitController < ApplicationController
  require 'compose'

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

    @kernel = @from.
      call(
           "business_units"
           )

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
    xml.business_units(:sql => @sql,:count => @count) {

      @results = ActiveRecord::Base.connection.execute(@sql)
      @results.each do |r| 
        xml.business_unit(r)
      end
    }

    if self.params["format"] == "xml"
      render :xml => @xml
    else
      xslt = XML::XSLT.new()
      xslt.xml = @xml
 
      xslt.parameters = {
      }
      
      xslt.xsl = File.read("public/stylesheets/business_units.xsl")
      @out = xslt.serve()

      render :xml => @out
    end
  end

end
