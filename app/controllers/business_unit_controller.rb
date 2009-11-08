require 'xml/xslt'

class BusinessUnitController < ApplicationController
  def create
  end

  def read
  end

  def update
  end

  def delete
  end

  def index
    @xml = ""
    xml = Builder::XmlMarkup.new(:target => @xml, :indent => 2 )

    @sql = "SELECT * FROM business_units INNER JOIN people ON (true)"

    @count_sql = "SELECT count(*) FROM (" + @sql + ") AS count"
    @count = ActiveRecord::Base.connection.execute(@count_sql)[0]['count']

    xml.business_units(:sql => @sql,:count => @count) {


      @results = ActiveRecord::Base.connection.execute(@sql)
      @results.each do |r| 
        xml.business_unit(
                          :name => r["name"],
                          :address => r["address"],
                          :id => r["id"],
                          :created_at => r["created_at"]
                          )
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
