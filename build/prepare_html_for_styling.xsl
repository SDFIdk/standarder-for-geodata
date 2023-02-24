<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:x="http://www.w3.org/1999/xhtml" exclude-result-prefixes="x">
    <!--
    html-version: see https://www.saxonica.com/documentation11/index.html#!xsl-elements/output og 
    https://www.w3.org/TR/xslt-30/
    include-content-type: meta-tag med Content-Type er ikke nødvendig, da <meta charset="utf-8"/> allerede er til stede
    omit-xml-declaration: hvis ikke til stede (default: no), kommer der en fejl på https://validator.w3.org,
    "XML processing instructions are not supported in HTML"
    -->
    <xsl:output method="xhtml" html-version="5.0" include-content-type="no" omit-xml-declaration="yes" indent="no" />
    <!-- Kopiér (medmindre et andet template er "matched") -->
    <xsl:template match="/|@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    <!-- Tilføj data-theme -->
    <xsl:template match="x:html">
        <html xmlns="http://www.w3.org/1999/xhtml" lang="da" data-theme="light">
            <xsl:apply-templates select="@*|node()" />
        </html>
    </xsl:template>
    <!-- Kopiér CSS som det er, uden XML-escaping af f.eks. > tegn -->
    <xsl:template match="x:style">
        <style>
            <xsl:value-of disable-output-escaping="yes" select="text()" />
        </style>
    </xsl:template>
    <!-- Transformér header; tilføj container for layout -->
    <xsl:template match="x:body">
        <body>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="x:div[@id='header']" />
            <div class="ds-container ds-grid-1-2">
                <xsl:apply-templates select="x:div[@id='header']/x:div[@id='toc']"/>
                <xsl:apply-templates select="x:div[@id='content']"/>
            </div>
        </body>
    </xsl:template>
    <!-- Tilføj header element med logo, navn og hjemmeside (som står i "email") -->
    <xsl:template match="x:div[@id='header']">
        <header id="header" data-theme="dark" class="ds-padding">
            <div class="ds-container">
                <a class="ds-logo ds-logo-pull-left">
                    <xsl:attribute name="href" select="x:div/x:span[@id='email']/x:a/text()" />
                    <xsl:value-of select="x:div[@class='details']/x:span[@id='author']/text()" />
                </a>
            </div>
            <xsl:copy select="x:h1">
                <xsl:attribute name="class" select="'ds-container'" />
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
            <xsl:apply-templates select="x:div[@class='details']"/>
        </header>
    </xsl:template>
    <!-- Kopiér ikke author og email, er allerede kopieret ind i headeren -->
    <xsl:template match="x:div[@class='details']">
        <div class="details ds-container">
            <xsl:copy-of select="x:span[@id='revnumber']"/>
            <xsl:text> </xsl:text>
            <xsl:copy-of select="x:span[@id='revdate']"/>
        </div>
    </xsl:template>
    <!-- Tilføj nav element -->
    <xsl:template match="x:div[@id='toc']">
        <div id="toc" class="toc">
            <xsl:copy select="x:div[@id='toctitle']">
                <xsl:attribute name="class" select="'ds-padding'" />
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
            <nav class="ds-nav-vertical">
                <xsl:apply-templates select="x:ul"/>
            </nav>
        </div>
    </xsl:template>
    <!-- Anvend main i stedet for div -->
    <xsl:template match="x:div[@id='content']">
        <main class="ds-padding">
            <xsl:apply-templates select="@*|node()"/>
        </main>
    </xsl:template>
    <!-- Links der ikke peger på et sted i samme side skal åbnes i et nyt faneblad -->
    <xsl:template match="x:a" name="addTargetBlank">
        <xsl:element name="x:a">
            <xsl:if test="not(starts-with(@href, '#'))">
                <xsl:attribute name="target" select="'_blank'" />
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>