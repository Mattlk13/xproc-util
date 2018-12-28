<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pos="http://exproc.org/proposed/steps/os"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:xe="http://degruyter.com/xmlns/xml2epub"
  version="1.0"
  name="imagemagick"
  type="tr:imagemagick">
  
  <p:documentation>
    This is an XProc wrapper for ImageMagick. The ImageMagick executable 
    needs to be installed on your system.
  </p:documentation>
  
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Provides a c:result representation of the converted file.
    </p:documentation>  
  </p:output>
  
  <p:option name="href" required="true">
    <p:documentation>image file to be converted</p:documentation>
  </p:option>
  <p:option name="outdir" select="'converted'">
    <p:documentation>dir or path to the output directory. If the directory
                     don't exists, it will be created.</p:documentation>
  </p:option>
  <p:option name="format" select="'jpg'">
    <p:documentation>The image will be converted into this format</p:documentation>
  </p:option>
  <p:option name="imagemagick-options" select="''">
    <p:documentation>Provide additional options for ImageMagick</p:documentation>
  </p:option>
  <p:option name="imagemagick-path" select="''">
    <p:documentation>Installation path for ImageMagick</p:documentation>
  </p:option>  
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:variable name="image-ext" select="replace($href, '^.+?\.([a-z]+)', '$1', 'i')"/>
  <p:variable name="basename" select="replace($href, '^.+/(.+)\.[a-z]+$', '$1', 'i')"/>
  <p:variable name="image-outpath" select="concat($outdir, '/', $basename, '.', $format)"/>
  
  <pos:info name="os-info"/>
  
  <tr:file-uri name="imagemagick-path" cx:depends-on="os-info">
    <p:with-option name="filename" select="if($imagemagick-path eq '')
                                           then if(matches(/c:result/@os-name, 'windows', 'i')) 
                                                then 'C:/cygwin64/bin/convert.exe'
                                                else '/usr/bin/convert'
                                           else $imagemagick-path"/>
  </tr:file-uri>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('xe-convert-image/', $basename, '/imagemagick-path')"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message name="msg1">
    <p:with-option name="message" select="'[info] imagemagick path: ', /c:result/@os-path"/>
  </cx:message>
  
  <p:sink/>
  
  
  <tr:file-uri name="file-path">
    <p:with-option name="filename" select="$href"/>
  </tr:file-uri>
  
  <p:sink/>
  
  <tr:file-uri name="outfile-path">
    <p:with-option name="filename" select="$image-outpath"/>
  </tr:file-uri>
  
  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('xe-convert-image/', $basename, '/outpath')"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cxf:mkdir fail-on-error="true" name="mkdir">
    <p:with-option name="href" select="replace(/c:result/@href, '^(.+)/.+$', '$1')"/>
  </cxf:mkdir>
  
  <tr:store-debug>
    <p:input port="source">
      <p:pipe port="result" step="file-path"/>
    </p:input>
    <p:with-option name="pipeline-step" select="concat('xe-convert-image/', $basename, '/sourcefile')"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:group name="exec-group" cxf:depends-on="mkdir">
    <p:variable name="image-stripped-outpath" 
                select="replace(/c:result/@os-path,
                        '^[a-z]:/cygwin[\d]*(.+)$',
                        '$1', 'i')">
      <p:pipe port="result" step="outfile-path"/>
    </p:variable>
    <p:variable name="arg-separator" select="' '"/>
    
    <cx:message name="msg2">
      <p:with-option name="message" select="'[info] ', /c:result/@os-path">
        <p:pipe port="result" step="outfile-path"/>
      </p:with-option>
    </cx:message>
    
    <p:exec name="exec" wrap-error-lines="true" wrap-result-lines="true" result-is-xml="false" cx:depends-on="imagemagick-path">
      <p:with-option name="command" select="/c:result/@os-path">
        <p:pipe port="result" step="imagemagick-path"/>
      </p:with-option>
      <p:with-option name="arg-separator" select="$arg-separator"/>
      <p:with-option name="args" 
                     select="string-join(('-verbose -format',
                                          $format,
                                          $imagemagick-options,
                                          /c:result/@os-path, 
                                          $image-stripped-outpath
                                          ), 
                                          $arg-separator)">
        <p:pipe port="result" step="file-path"/>
      </p:with-option>
      <p:input port="source">
        <p:empty/>
      </p:input>
    </p:exec>
    
    <p:wrap-sequence wrapper="imagemagick" name="wrap-imagemagick-output-for-debugging">
      <p:input port="source">
        <p:pipe port="result" step="exec"/>
        <p:pipe port="errors" step="exec"/>
        <p:pipe port="exit-status" step="exec"/>
      </p:input>
    </p:wrap-sequence>
    
    <tr:store-debug>
      <p:with-option name="pipeline-step" select="concat('xe-convert-image/', $basename, '/imagemagick')"/>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>
    
  </p:group>
  
</p:declare-step>