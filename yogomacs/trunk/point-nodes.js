function is_point_node(node) {
  if (node.nodeType  == Node.ELEMENT_NODE/*1*/) {
    var id = node.readAttribute("id");
    if (id === null)
      return false;
    else if (id.match("^point:"))
      return true;
    else if (id.match("^font-lock:"))
      return true;
    else
      return false;
  } else {
    return false;
  }
}

function point_nodes(node) {
  var nodes = node.childNodes;
  var c = 0;
  var pnodes = new Array();
  
  for (var i = 0; i < nodes.length; i++) {
    if (is_point_node(nodes[i])) {
      pnodes[c++] = nodes[i];
    }
  }
  return pnodes;
}

window.PointNodes = true;