# mass-rename-files

Renames XML file references and physical files that correspond to the file references.

## Ports

* `input` a XML document
* `result` the XML document with the patched file references
* `report` a `c:result` document with a listing of the moved files and potential errors 

## Options

* `attribute-name` the name of the attribute containing the file references 
* `regex-match` regular expression which matches the file reference 
* `regex-replace` the replacement string

## Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0">
  
  <!-- rename file extension to jpg -->
  
  <p:input port="source">
    <p:inline>
      <images>
        <image fileref="file:/C:/home/Martin/images/myimage01.png"/>
        <image fileref="file:/C:/home/Martin/images/myimage02.png"/>
      </images>
    </p:inline>
  </p:input>
  
  <p:output port="result" primary="true"/>
  <p:output port="report">
    <p:pipe port="report" step="mass-rename"/>
  </p:output>
  
  <p:import href="mass-rename-files.xpl"/>
  
  <tr:mass-rename-files name="mass-rename">
    <p:with-option name="attribute-name" select="'fileref'"/>
    <p:with-option name="regex-match" select="'^(.+)\..+'"/>
    <p:with-option name="regex-replace" select="'$1.jpg'"/>
  </tr:mass-rename-files>
  
</p:declare-step>
```
