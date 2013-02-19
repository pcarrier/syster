module Kolekt; module Reporters; class Base
  def report name, payload
  end

  # Stupid by default
  def wants dry_payload
    true
  end

  def finish
  end
end; end; end
