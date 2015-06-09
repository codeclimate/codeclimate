module Factory
  extend self

  def create_correct_yaml
    %{
      engines:
        rubocop:
          enabled: true
    }
  end

  def create_yaml_with_errors
    %{
      engkxhfgkxfhg: sdoufhsfogh: -
      0-
      fgkjfhgkdjfg;h:;
        sligj:
      oi i ;
    }
  end

  def create_yaml_with_warning
    %{
      engines:
      unknown_key:
    }
  end

  def create_yaml_with_nested_warning
    %{
      engines:
        rubocop:
    }
  end

  def create_yaml_with_nested_and_unnested_warnings
    %{
      engines:
        rubocop:
          enabled: true
        jshint:
          not_enabled
      strange_key:
    }
  end
end
