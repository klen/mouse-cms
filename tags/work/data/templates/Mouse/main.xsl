<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "../dtd/entities.dtd">
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Output -->
<xsl:output
	doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
/>

<!-- Include -->
<xsl:include href="../main.xsl"/>
<xsl:include href="forms.xsl"/>
<xsl:include href="objects.xsl"/>

<!-- Gooo -->
<xsl:template match="/node()">
	<html lang="{@lang}">
		<!-- header -->
		<xsl:call-template name="header"/>
		<!-- body -->
		<xsl:call-template name="body"/>
	</html>
</xsl:template>

<!-- Body -->
<xsl:template name="body">
	<body id="{/document/header/object-id}">
		<xsl:apply-templates select="/document/body" />
		<xsl:apply-templates select="//js_footer" />
	</body>
</xsl:template>

<!-- CONTENT* -->
<xsl:template match="document/body">
	<!-- header -->
	<div id="header">
		<a href="http://{/document/system/site/.}" title="{/document/header/main_url/.}">
			<h1><xsl:value-of select="/document/header/document_name"/></h1>
		</a>
		<xsl:apply-templates select="//menu"/>
        <form method="get" action="/search/" id="quick-search">
		    <input type="text" name="phrase" class="text" id="search" value="Поиск выключен :)" title="Поиск" />
            <input type="image" src="/images/search.gif" name="search" id="search" alt="Найти" />
        </form>
	</div>
	<!-- content -->
	<div id="content">
		<div id="container">
			<xsl:apply-templates select="/document/body/block[@mode=1]"/>
		</div>
	</div>
				
	<!-- sidebar -->
	<div id="sidebar">
	   	<xsl:apply-templates select="/document/body/block[@mode=2]"/>
	   	<xsl:apply-templates select="//badges"/>
	</div>
					
	<!-- FOOTER -->
	<div id="footer">
		<div id="copyright"><p id="mouse"></p>© 2006 KLeN</div>
		<p id="stat">Справка | Техническая поддержка | О программе</p>
	</div>
</xsl:template>
<!-- CONTENT# -->


<!-- BLOCK* -->
<xsl:template match="/document/body/block">
	<xsl:choose>
		<xsl:when test=" @style = 0 ">
			<xsl:apply-templates select="block_content"/>
		</xsl:when>
		<xsl:when test=" @mode = 1 ">
			<div id="{@name}">
				<h3><span><xsl:value-of select="block_name" /></span></h3>
				<xsl:apply-templates select="block_content"/>
			</div>
		</xsl:when>
		<xsl:when test=" @mode = 2 ">
			<div id="{@name}">
			<h3><span><xsl:value-of select="block_name" /></span></h3>
			<ul><xsl:apply-templates select="block_content"/></ul>
			</div>
		</xsl:when>
		<xsl:otherwise>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!-- BLOCK# -->

<!-- topmenu -->
<xsl:template match="menu">
	<ul id="topnav">
		<xsl:apply-templates select="/document/navigation/branche[@is_show_in_menu=1]" mode="topmenu" />
	</ul>
</xsl:template>
<xsl:template match="/document/navigation/branche[@is_show_in_menu=1]" mode="topmenu"> 
		<li>
			<xsl:if test="not(@in=1) or (@hit=0)">
				<a href="{@full_path}" title="{@document_name}"><xsl:value-of select="@name"/>
				<xsl:call-template name="topmenu" /></a>
			</xsl:if>
			<xsl:if test="(@in=1) and not(@hit=0)">
				<b><xsl:value-of select="@name"/></b>
				<xsl:call-template name="topmenu" />
       		</xsl:if>
		</li>
</xsl:template>
<xsl:template name="topmenu"> 
	<xsl:if test = "not(position()=last())" >
       	<xsl:text >| </xsl:text>
    </xsl:if>
</xsl:template>

<!-- sidemenu -->
<xsl:template match="sidemenu">
		<xsl:apply-templates select="/document/navigation/branche[@is_show_in_menu=1]" mode="sidemenu" />
</xsl:template>
<xsl:template match="/document/navigation/branche[@is_show_in_menu=1]|/document/navigation//branche/branche[@is_show_in_menu=1]" mode="sidemenu" >
			<li>
				<xsl:if test="not (@in=1)"><a href="{@full_path}" title="{@description}"><xsl:value-of select="@name"/></a></xsl:if>
				<xsl:if test="(@in=1)"><b><xsl:value-of select="@name"/></b></xsl:if>
				<xsl:if test="(./branche[@is_show_in_menu=1])"><ul><xsl:apply-templates select="//branche/branche" mode="sidemenu" /></ul></xsl:if>
			</li>
</xsl:template>

<!-- sitemap -->
<xsl:template match="map">
<ul>
	<xsl:apply-templates select="/document/navigation/branche" mode="sitemap" />
</ul>
</xsl:template>
<xsl:template match="/document/navigation/branche|/document/navigation//branche/branche" mode="sitemap">
<xsl:if test="@is_show_on_sitemap = 1">
		<li>
			<a href="{@full_path}" title="{@document_name}"><xsl:value-of select="@name"/></a> | <small><xsl:value-of select="@description"/></small>
			<xsl:if test="(./branche[@is_show_on_sitemap=1])"><ul><xsl:apply-templates select="//branche/branche" mode="sitemap" /></ul></xsl:if>
		</li>
</xsl:if>
</xsl:template>

<!-- control -->
<xsl:template match="control">
	<div class="control">
		<xsl:apply-templates select="//addcontrol" />
		&nbsp;
		<xsl:apply-templates />
	</div>
	<div id="loadingAjax"><li><img src="/images/loading.gif"/> загрузка </li></div>
	<div id="Ajax"></div>
</xsl:template>

<xsl:template match="quote">
	<p class="p1"><span><xsl:value-of select="."/></span></p>
</xsl:template>

<xsl:template match="author">
		<p class="p2"><span><xsl:value-of select="."/></span></p>
</xsl:template>

</xsl:stylesheet>