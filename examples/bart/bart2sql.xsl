<?xml version="1.0"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">
  <xsl:output method="text" encoding="utf-8" />

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="station">

    INSERT INTO station (name,abbr) 
         VALUES (
    $$<xsl:value-of select="name"/>$$,
    $$<xsl:value-of select="abbr"/>$$
    );
    
  </xsl:template>


</xsl:stylesheet>
