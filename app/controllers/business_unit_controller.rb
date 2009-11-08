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
    xml.business_units {
      @units = BusinessUnit.find(:all)

      @units.each do |u|
        xml.business_unit(
                          :id => u.attributes["id"],
                          :name => u.attributes["name"],
                          :address => u.attributes["address"]
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
