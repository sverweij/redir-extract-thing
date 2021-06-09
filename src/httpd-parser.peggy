config = (vhost_section)*
       
vhost_section = _ vhost_open_tag _ content:vhost_content _ vhost_close_tag _ {
  	return content
}

vhost_open_tag = "<VirtualHost *>" 
vhost_close_tag = "</VirtualHost>"
vhost_content = vhostContent:(vhost_statement)* {
  return vhostContent.reduce(
    (pAll, pCurrent) => {
      switch(Object.keys(pCurrent)[0]) {
        case "redirect": {
          pAll["redirects"] = pAll["redirects"] || [];

          pAll.redirects.push(Object.values(pCurrent)[0])
          return pAll
        }
        case "conditional": {
          pAll["conditionals"] = pAll["conditionals"] || [];

          pAll.conditionals.push(Object.values(pCurrent)[0])
          return pAll
        }
        default: {
          return { ...pAll, ...pCurrent }
        }
      }
    }, 
    {}
  )
}

vhost_statement = serverName:server_name {return { serverName }} /
  serverAliases:server_alias {return {serverAliases}}/
  documentRoot:document_root {return {documentRoot}}/ 
  redirect:redirect {return {redirect}}/
  conditional:if_section {return {conditional}}

if_section = _ condition:if_open_tag _ redirects:redirect* _ if_close_tag _ {
  return {condition, redirects}
}
// todo: conditions are typically in quotes - this is less strict
if_open_tag = "<If" _ "\"" condition:[^"]* "\"" _ ">" {
  return condition.join("")
}
if_close_tag = "</If>"

server_name = _ "ServerName" _ serverName:urlishpattern { 
  return serverName
}

server_alias = _ "ServerAlias" _ serverAliasses:[^\r\n]+  { 
  return serverAliasses.join("")
}

document_root = _ "DocumentRoot" _ documentRoot:urlishpattern { 
  return documentRoot
}

// todo: those 301's are of course haphazard hacks - works for current context, not for the general one.
redirect = _ ("RedirectPermanent" / "RedirectMatch 301"/ "Redirect 301") _ from:urlishpattern _ to:urlishpattern _ {
  return {
    from,
    to
  }
}

urlishpattern =  _ "\"" chars:[^"]+ "\"" _
{
  return chars.join("")
}
  /  chars:[^ \t\r\n]+
{
  return chars.join("")
}

slcomment
    = slcomstart comment:(slcomtok)*
    {
      return {
      	comment: comment.join("").trim()
      }
    }
slcomstart = "#"
slcomtok   = [^\r\n]


whitespace "whitespace"
    = c:[ \t] {return c}

lineend "line end"
    = c:[\r\n] {return c}
_
   = (whitespace / lineend/ slcomment)*

