embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"crate2\"\n"
  "material: \"/assets/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/images/crates.atlas\"\n"
  "}\n"
  ""
  scale {
    x: 0.3
    y: 0.3
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"anchor\"\n"
  "mask: \"player\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "  }\n"
  "  data: 24.0\n"
  "  data: 24.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
