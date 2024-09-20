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
            <div class="ds-container">
                <xsl:apply-templates select="x:div[@id='header']/x:div[@id='toc']"/>
                <xsl:apply-templates select="x:div[@id='content']"/>
            </div>
            <div class="ds-padding">
                <nav>
                    <a id="link_to_toc" href="#toc" role="button">Til indholdsfortegnelsen</a>
                </nav>
            </div>
        </body>
    </xsl:template>
    <!-- Tilføj header element med logo, navn og hjemmeside (som står i "email") -->
    <xsl:template match="x:div[@id='header']">
        <header id="header" class="ds-header">
            <div class="ds-container">
                <ds-logo-title title="Anbefalede standarder for geodata">
                    <xsl:attribute name="title" select="x:h1/text()" />
                    <xsl:attribute name="byline" select="x:div[@class='details']/x:span[@id='author']/text()" />
                </ds-logo-title>
                <xsl:copy select="x:h1">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
                <p class="manchet">
                    <xsl:value-of select="../../x:head/x:meta[@name='description']/@content" />
                </p>
                <xsl:apply-templates select="x:div[@class='details']"/>
            </div>
        </header>
    </xsl:template>
    <!-- Kopiér ikke author og email, er allerede kopieret ind i headeren -->
    <xsl:template match="x:div[@class='details']">
        <xsl:copy-of select="x:span[@id='revnumber']"/>
        <xsl:text> </xsl:text>
        <xsl:copy-of select="x:span[@id='revdate']"/>
    </xsl:template>
    <!-- Tilføj nav element -->
    <xsl:template match="x:div[@id='toc']">
        <div id="toc" class="toc ds-padding">
            <nav class="ds-nav-vertical">
                <h2>
                    <xsl:value-of select="x:div[@id='toctitle']/text()" />
                </h2>
                <xsl:apply-templates select="x:ul"/>
            </nav>
        </div>
    </xsl:template>
    <!-- Anvend main -->
    <xsl:template match="x:div[@id='content']">
        <main>
            <xsl:apply-templates select="@*|node()"/>
        </main>
    </xsl:template>
    <!-- Anvend aside -->
    <xsl:template match="x:div[@class='paragraph bibliographicaldetails']">
        <aside class="bibliographicaldetails">
            <xsl:apply-templates select="@*[local-name()!='class']|node()"/>
        </aside>
    </xsl:template>
    <!-- Anvend cite -->
    <xsl:template match="x:span[@class='cite']">
        <cite>
            <xsl:apply-templates select="@*|node()"/>
        </cite>
    </xsl:template>
    <!-- Links der ikke peger på et sted i samme side skal åbnes i et nyt faneblad -->
    <xsl:template match="x:a" name="addTargetBlank">
        <xsl:element name="x:a">
            <xsl:if test="exists(@href) and not(starts-with(@href, '#'))">
                <xsl:attribute name="target" select="'_blank'" />
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
            <xsl:if test="exists(@href) and not(starts-with(@href, '#'))">
                <span class="icon--mdi icon--mdi--open-in-new icon--mdi--open-in-new-custom"></span>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- Se https://alfa.siteimprove.com/rules/sia-r79 -->
    <xsl:template match="x:pre">
        <pre>
            <code>
                <xsl:apply-templates select="@*|node()"/>
            </code>
        </pre>
    </xsl:template>
</xsl:stylesheet>