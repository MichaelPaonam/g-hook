components {
  id: "cable_line"
  component: "/main/hook/cable_line.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"default\"\n"
  "material: \"/main/hook/cable.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/hook/cable.atlas\"\n"
  "}\n"
}
