module Java
  class Annotatable
    attr_reader :annotations
    def initialize(annotations)
      @annotations = annotations
    end

    def has_annotation?(annotation_name)
      @annotations.any? { |hash| hash.keys.any? { |key| key == annotation_name } }
    end

    def get_annotation(annotation_name)
      hash = @annotations.find { |a| a.keys.include?(annotation_name) }
      hash[annotation_name] unless hash.nil?
    end
  end
end
