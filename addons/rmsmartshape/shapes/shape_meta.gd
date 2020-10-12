tool
extends SS2D_Shape_Base
class_name SS2D_Shape_Meta, "../assets/meta_shape.png"

"""
This shape will set the point_array data of all children shapes
"""

var _cached_shape_children: Array = []


#############
# OVERRIDES #
#############
func _init():
	._init()
	_is_instantiable = true


func _ready():
	for s in _get_shapes(self):
		_add_to_meta(s)
	call_deferred("_update_cached_children")
	._ready()


func _draw():
	pass

func remove_child(node: Node):
	_remove_from_meta(node)
	call_deferred("_update_cached_children")
	.remove_child(node)

func add_child(node: Node, legible_unique_name: bool = false):
	_add_to_meta(node)
	call_deferred("_update_cached_children")
	.add_child(node, legible_unique_name)


func add_child_below_node(node: Node, child_node: Node, legible_unique_name: bool = false):
	_add_to_meta(child_node)
	call_deferred("_update_cached_children")
	.add_child_below_node(node, child_node, legible_unique_name)


func _on_dirty_update():
	pass


func set_as_dirty():
	_update_shapes()


########
# META #
########
func _update_cached_children():
	_cached_shape_children = _get_shapes(self)


func _get_shapes(n: Node, a: Array = []) -> Array:
	for c in n.get_children():
		if c is SS2D_Shape_Base:
			a.push_back(c)
		_get_shapes(c, a)
	return a


func _add_to_meta(n: Node):
	if not n is SS2D_Shape_Base:
		return
	# Assign node to have the same point array data as this meta shape
	n.set_point_array(_points, false)
	n.connect("points_modified", self, "_update_shapes", [[n]])


func _update_shapes(except: Array = []):
	_update_curve(_points)
	for s in _cached_shape_children:
		if not except.has(s):
			s.set_as_dirty()
			s._update_curve(s.get_point_array())


func _remove_from_meta(n: Node):
	if not n is SS2D_Shape_Base:
		return
	# Make Point Data Unique
	n.set_point_array(n.get_point_array(), true)
	n.disconnect("points_modified", self, "_update_shapes")
