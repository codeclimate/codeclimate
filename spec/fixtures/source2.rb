class Thing
  def enable_engine(engine_name)
    if engine_present?(engine_name)
      @config["engines"][engine_name]["enabled"] = true
    else
      @config["engines"][engine_name] = { "enabled" => true }
      enable_default_config(engine_name) if default_config(engine_name)
    end
  end
end
