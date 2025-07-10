<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:x="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="x">
    <!--
    html-version: se https://www.saxonica.com/documentation11/index.html#!xsl-elements/output og 
    https://www.w3.org/TR/xslt-30/
    include-content-type: meta-tag med Content-Type er ikke nødvendig, da <meta charset="utf-8"/> allerede er til stede
    omit-xml-declaration: hvis ikke til stede (default: no), kommer der en fejl på https://validator.w3.org,
    "XML processing instructions are not supported in HTML"
    -->
    <xsl:output
        method="xhtml"
        html-version="5.0"
        include-content-type="no"
        omit-xml-declaration="yes"
        indent="no" />
    <!-- Kopiér (medmindre et andet template er "matched") -->
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:variable
        name="designsystemVersion"
        select="'8'" />

    <xsl:variable
        name="designsystemUrl"
        select="'https://cdn.dataforsyningen.dk/assets/designsystem/v' || $designsystemVersion" />

    <xsl:variable
        name="exitSiteIcon"
        select="document($designsystemUrl || '/icons/exitsite.svg')" />
        
    <xsl:variable
        name="listIcon"
        select="document($designsystemUrl || '/icons/list.svg')" />
        
    <!-- Tilføj data-theme -->
    <xsl:template match="x:html">
        <html
            xmlns="http://www.w3.org/1999/xhtml"
            lang="da"
            data-theme="light">
            <xsl:apply-templates select="@*|node()" />
        </html>
    </xsl:template>
    <!-- Kopiér CSS som det er, uden XML-escaping af f.eks. > tegn -->
    <xsl:template match="x:style">
        <style>
            <xsl:value-of
                disable-output-escaping="yes"
                select="text()" />
        </style>
    </xsl:template>
    <!-- Transformér header; tilføj container for layout -->
    <xsl:template match="x:body">
        <body>
            <xsl:apply-templates select="@*" />
            <div
                id="buttons"
                class="ds-flex-row">
                <nav>
                    <a
                        id="link_to_toc"
                        href="#toc"
                        role="button"
                        title="Til indholdsfortegnelsen">
                        <xsl:copy-of select="$listIcon" />
                    </a>
                </nav>
                <ds-theme-toggle />
            </div>
            <xsl:apply-templates select="x:div[@id='header']" />
            <div class="grid-container">
                <xsl:apply-templates select="x:div[@id='header']/x:div[@id='toc']" />
                <div id="text" class="ds-container">
                    <xsl:apply-templates select="x:div[@id='content']" />
                    <xsl:apply-templates select="x:div[@id='footnotes']" />
                </div>
            </div>
        </body>
    </xsl:template>
    <!-- Tilføj header element med logo, navn og hjemmeside (som står i "email") -->
    <xsl:template match="x:div[@id='header']">
        <header
            id="header"
            class="ds-header">
            <div class="ds-container">
                <ds-logo-title>
                    <xsl:attribute
                        name="title"
                        select="x:h1/text()" />
                    <xsl:attribute
                        name="byline"
                        select="x:div[@class='details']/x:span[@id='author']/text()" />
                </ds-logo-title>
                <xsl:copy select="x:h1">
                    <xsl:apply-templates select="@*|node()" />
                </xsl:copy>
                <p class="manchet">
                    <xsl:value-of select="../../x:head/x:meta[@name='description']/@content" />
                </p>
                <xsl:apply-templates select="x:div[@class='details']" />
            </div>
        </header>
    </xsl:template>
    <!-- Kopiér ikke author og email, er allerede kopieret ind i headeren -->
    <xsl:template match="x:div[@class='details']">
        <xsl:copy-of select="x:span[@id='revnumber']" />
        <xsl:text> </xsl:text>
        <xsl:copy-of select="x:span[@id='revdate']" />
    </xsl:template>
    <!-- Tilføj nav element -->
    <xsl:template match="x:div[@id='toc']">
        <div
            id="toc"
            class="toc ds-padding">
            <nav class="ds-nav-vertical">
                <h2>
                    <xsl:value-of select="x:div[@id='toctitle']/text()" />
                </h2>
                <xsl:apply-templates select="x:ul" />
            </nav>
        </div>
    </xsl:template>
    <!-- Anvend main -->
    <xsl:template match="x:div[@id='content']">
        <main>
            <xsl:apply-templates select="@*|node()" />
        </main>
    </xsl:template>
    <!-- Anvend section -->
    <xsl:template match="x:div[matches(@class, 'sect\d')]">
        <section>
            <xsl:apply-templates select="node()" />
        </section>
    </xsl:template>
    <!-- Sæt fodnoterne i en section -->
    <xsl:template match="x:div[@id='footnotes']">
        <section class="small">
            <xsl:apply-templates select="@*|node()" />
        </section>
    </xsl:template>
    <!-- Anvend cite -->
    <xsl:template match="x:span[@class='cite']">
        <cite>
            <xsl:apply-templates select="@*|node()" />
        </cite>
    </xsl:template>
    <!-- Anvend figure og figcaption -->
    <xsl:template match="x:div[@class='imageblock']">
        <figure>
            <xsl:apply-templates select="@id" />
            <xsl:apply-templates select="x:div[@class='content']/x:img" />
            <figcaption>
                <xsl:apply-templates select="x:div[@class='title']/node()" />
            </figcaption>
        </figure>
    </xsl:template>
    <!-- Links der ikke peger på et sted i samme side skal åbnes i et nyt faneblad -->
    <xsl:template
        match="x:a"
        name="addTargetBlank">
        <xsl:element name="x:a">
            <xsl:if test="exists(@href) and not(starts-with(@href, '#'))">
                <xsl:attribute
                    name="target"
                    select="'_blank'" />
                <xsl:attribute
                    name="rel"
                    select="'noreferrer noopener'" /><!-- See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#security_and_privacy -->
            </xsl:if>
            <xsl:apply-templates select="@*|node()" />
            <xsl:if test="exists(@href) and not(starts-with(@href, '#'))">
                <xsl:copy-of select="$exitSiteIcon" />
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- Anvend aside -->
    <xsl:template match="x:div[@class='paragraph bibliographicaldetails']">
        <aside class="bibliographicaldetails">
            <xsl:apply-templates select="@*[local-name()!='class']|node()" />
        </aside>
    </xsl:template>
</xsl:stylesheet>