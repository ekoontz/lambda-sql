<?xml version="1.0"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tohtml="http://github.com/ekoontz/lambda-sql" 
    version="1.0">

  <xsl:include href="public/stylesheets/lambda_sql.xsl"/>

  <xsl:template match="*" mode="page_specific_meta">
    <link href="/stylesheets/sql_view.css"
	  media="screen" rel="stylesheet" type="text/css" />
  </xsl:template>

  <xsl:template match="/">
    <xsl:apply-templates select="." mode="page">
      <xsl:with-param name="title">SQL View List</xsl:with-param>
      <xsl:with-param name="onload"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="header">
    <xsl:apply-templates select="." mode="header_main"/>
    <h2>SQL views</h2>
  </xsl:template>

  <xsl:template match="html" mode="add_form_markup">
    <div class="sql_form">
      <form action="?">
	<xsl:apply-templates select="tohtml:*"/>
	<div class="submit"><input type="submit"/></div>
      </form>
    </div>
  </xsl:template>

  <xsl:template match="tohtml:*">
    <!-- translate classes, form names and values in source, if any, to appropriate html markup. -->
    <xsl:choose>
      <xsl:when test="@class = 'fill-in'">
	<xsl:element name="{name()}">
	  <xsl:attribute name="colspan">2</xsl:attribute>
	  <input value="{.}" name="{@name}"/>
	</xsl:element>
      </xsl:when>
      <xsl:when test="@class = 'dropdown-tables'">
	<xsl:element name="{name()}">
	  <xsl:apply-templates select="ancestor::view/metadata/tables" mode="dropdown">
	    <xsl:with-param name="form_input_name" select="'table'"/>
	    <xsl:with-param name="selected" select="."/>
	  </xsl:apply-templates>
	</xsl:element>
      </xsl:when>
      <xsl:when test="@class = 'dropdown-columns'">
	<xsl:element name="{name()}">
	  <xsl:apply-templates select="ancestor::view/metadata/columns" mode="dropdown">
	    <xsl:with-param name="form_input_name" select="'column'"/>
	    <xsl:with-param name="selected" select="."/>
	    <xsl:with-param name="table_alias" select="@table_alias"/>
	    <xsl:with-param name="filterby" select="@filterby"/>
	  </xsl:apply-templates>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="{name()}">
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="view" mode="body">
    <form action="?" method="get">
      <xsl:apply-templates select="html" mode="add_form_markup"/>
      <pre>
	<xsl:value-of select="new_sql"/>
      </pre>
      <div>
	<table>
	  <tr>
	    <td>
	      <xsl:apply-templates select="metadata/tables" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'table'"/>
		<xsl:with-param name="selected" select="metadata/params/@table"/>
	      </xsl:apply-templates>
	    </td>
	    <td>table_a</td>
	    <td>
	      <xsl:apply-templates select="metadata/joindirs" mode="dropdown">
		<xsl:with-param name="top">
		  <option/>
		</xsl:with-param>
		<xsl:with-param name="form_input_name" select="'joindir'"/>
		<xsl:with-param name="selected" select="metadata/params/@joindir"/>
	      </xsl:apply-templates>
	    </td>
	  </tr>
	</table>
	<div style="display:none">
	  <table>
	    <tr>
	      <td>
		<xsl:apply-templates select="metadata/tables" mode="dropdown">
		  <xsl:with-param name="form_input_name" select="'join1'"/>
		  <xsl:with-param name="selected" select="metadata/params/@join1"/>
		</xsl:apply-templates>
	      </td>
	      <td>table_b</td>
	      <td>ON</td>
	      <td>
		<xsl:apply-templates select="metadata/columns" mode="dropdown">
		  <xsl:with-param name="top">
		    <option>
		      <!-- will be selected if params/@jc1 is not defined. -->
		      TRUE
		    </option>
		  </xsl:with-param>
		  <xsl:with-param name="form_input_name" select="'jc1'"/>
		  <xsl:with-param name="selected" select="metadata/params/@jc1"/>
		  <xsl:with-param name="filterby" select="metadata/params/@table"/>
		  <xsl:with-param name="table_alias" select="'table_a'"/>
		</xsl:apply-templates>
	      </td>
	      <td>
		<select name="joinop1" onchange="submit()">
		  <option>=</option>
		  <option>&lt;</option>
		  <option>&lt;&gt;</option>
		  <option>&gt;</option>
		</select>
	      </td>
	      <td>
		<xsl:apply-templates select="metadata/columns" mode="dropdown">
		  <xsl:with-param name="top">
		    <option>
		      <!-- will be selected if metadata/params/@jc2 is not defined. -->
		      TRUE
		    </option>
		  </xsl:with-param>
		  <xsl:with-param name="form_input_name" select="'jc2'"/>
		  <xsl:with-param name="selected" select="metadata/params/@jc2"/>
		  <xsl:with-param name="filterby" select="metadata/params/@join1"/>
		  <xsl:with-param name="table_alias" select="'table_b'"/>
		</xsl:apply-templates>
	      </td>
	    </tr>
	  </table>
	</div>
      </div>
    </form>

    <div>
      <div class="pre">
	<xsl:value-of select="rows/@sql"/>
      </div>
	
      <xsl:apply-templates select="rows" mode="table">
	<xsl:with-param name="inputs">
	  <table style="display:none">
	    <xsl:apply-templates 
	       select="rows/@*[(position() mod 2) = 1][1]" 
	       mode="table_inputs_tr"/>
	    <xsl:apply-templates 
	       select="metadata/params/@*[(position() mod 2) = 1][1]" 
	       mode="table_inputs_tr"/>
	  </table>

	</xsl:with-param>

      </xsl:apply-templates>

    </div>
  </xsl:template>

    <!-- get rid of 'offset', 'count' etc. -->
  <xsl:template match="params/@offset" mode="table_inputs"/>
  <xsl:template match="@sql" mode="table_inputs"/>
  <xsl:template match="@count" mode="table_inputs"/>
  <xsl:template match="@limit" mode="table_inputs"/>
  <xsl:template match="@format" mode="table_inputs"/>

  <xsl:template match="rows/@*" mode="table_inputs_tr">
    <xsl:param name="offset">0</xsl:param>
    <tr>
      <xsl:apply-templates select="." mode="table_inputs"/>
      <xsl:apply-templates 
	 select="ancestor-or-self::rows/@*[((1 + $offset) * 2)]"
	 mode="table_inputs"/>
    </tr>
    <xsl:apply-templates select="ancestor-or-self::rows/@*[(position() mod 2) = 1][$offset + 2]" mode="table_inputs_tr">
      <xsl:with-param name="offset"><xsl:value-of select="$offset + 1"/></xsl:with-param>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="rows/@*" mode="table_inputs_tr">
    <xsl:param name="offset">0</xsl:param>
    <tr>
      <xsl:apply-templates select="." mode="table_inputs"/>
      <xsl:apply-templates 
	 select="ancestor-or-self::rows/@*[((1 + $offset) * 2)]"
	 mode="table_inputs"/>
    </tr>
    <xsl:apply-templates select="ancestor-or-self::rows/@*[(position() mod 2) = 1][$offset + 2]" mode="table_inputs_tr">
      <xsl:with-param name="offset"><xsl:value-of select="$offset + 1"/></xsl:with-param>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="metadata/params/@*" mode="table_inputs_tr">
    <xsl:param name="offset">0</xsl:param>
    <tr>
      <td>
	<xsl:apply-templates select="." mode="table_inputs"/>
      </td>
      <td>
	<xsl:apply-templates 
	   select="ancestor-or-self::metadata/params/@*[((1 + $offset) * 2)]"
	   mode="table_inputs"/>
      </td>
    </tr>
    <xsl:apply-templates select="ancestor-or-self::metadata/params/@*[(position() mod 2) = 1][$offset + 2]" mode="table_inputs_tr">
      <xsl:with-param name="offset"><xsl:value-of select="$offset + 1"/></xsl:with-param>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="column" mode="option">
    <xsl:param name="filterby"/>
    <xsl:param name="table_alias"/>
    <xsl:if test="@table_name = $filterby">
      <option><xsl:value-of select="$table_alias"/>.<xsl:value-of select="@name"/></option>
    </xsl:if>
  </xsl:template>

  <xsl:template match="joindir" mode="option">
    <xsl:param name="selected"/>
    <option>
      <xsl:if test="$selected = @name">
	<xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="@name"/> JOIN ...
    </option>
  </xsl:template>

</xsl:stylesheet>
  
