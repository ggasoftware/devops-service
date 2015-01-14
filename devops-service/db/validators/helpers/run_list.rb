module Validators
  class Helpers::RunList < Base

    RUN_LIST_REGEX = /\Arole|recipe\[[\w-]+(::[\w-]+)?\]\Z/

    def valid?
      @invalid_elements = @model.select {|l| (RUN_LIST_REGEX =~ l).nil?}
      @invalid_elements.empty?
    end

    def message
      invalid_elements_as_string = @invalid_elements.join("', '")
      "Invalid run list elements: '#{invalid_elements_as_string}'. Each element should be role or recipe."
    end
  end
end
