package id_to_name


main := title_for_node_id(data.node_id)

title_for_node_id(node_id) := title if {
  some path, obj
  walk(input, [path, obj])
  is_object(obj)
  obj.node_id == node_id
  title := obj.title
}
