require 'java_dissassembler/array'
require 'java_dissassembler/annotatable'
require 'java_dissassembler/class'
require 'java_dissassembler/method'
require 'java_dissassembler/field'

# See https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html for JVM Class Binary Specification
module Java
  class Dissassembler
    class << self
      CONSTANT_UTF8               = 1
      CONSTANT_INTEGER            = 3
      CONSTANT_FLOAT              = 4
      CONSTANT_LONG               = 5
      CONSTANT_DOUBLE             = 6
      CONSTANT_CLASS              = 7
      CONSTANT_STRING             = 8
      CONSTANT_FIELDREF           = 9
      CONSTANT_METHODREF          = 10
      CONSTANT_INTERFACEMETHODREF = 11
      CONSTANT_NAMEANDTYPE        = 12
      CONSTANT_METHODHANDLE       = 15
      CONSTANT_METHODTYPE         = 16
      CONSTANT_INVOKEDYNAMIC      = 18

      MAGIC = "\xCA\xFE\xBA\xBE".each_byte.to_a.freeze

      def dissassemble(bytes)
        if bytes.is_a?(Array)
          do_dissassemble(bytes)
        elsif bytes.is_a?(String)
          do_dissassemble(bytes.each_byte.to_a)
        else
          raise "Expected `bytes' to be Array of bytes or String of bytes"
        end
      end

      def dissassemble_file(path)
        File.open(path) do |file|
          dissassemble(file.read)
        end
      end

    private
      def do_dissassemble(bytes)
        raise "Missing magic number 0xCAFEBABE.  Not a .class file" unless bytes[0..3] == MAGIC

        minor = bytes[4..5].u2
        major = bytes[6..7].u2
        offset = 8

        # Constant Pool
        constant_pool = {}
        constant_pool_size = bytes[offset..offset + 1].u2 - 1
        offset += 2
        i = 0
        while i < constant_pool_size
          consumed, val, tag = constant_pool_info_size(bytes[offset..-1])
          i += 1 if !tag.nil? && ((tag == 5) || (tag == 6)) # Floats and Doubles take up two constant pool entries :/
          constant_pool[i + 1] = val unless val.nil?
          offset += consumed
          i += 1
        end

        # Class Info: 3 x u2 (access_flags, this_klass, super_klass)
        access_flags = bytes[offset..offset + 1].u2
        this_klass = constant_pool[constant_pool[bytes[offset + 2..offset + 3].u2]]
        super_klass = constant_pool[constant_pool[bytes[offset + 4..offset + 5].u2]]
        offset += 6

        # Interfaces
        interfaces = Array.new
        interfaces_count = bytes[offset..offset + 1].u2
        offset += 2
        interfaces_count.times do 
          interface_index = bytes[offset..offset + 1].u2
          interfaces << constant_pool[interface_index]
          offset += 2
        end

        # Fields
        fields = Array.new
        fields_count = bytes[offset..offset + 1].u2
        offset += 2
        fields_count.times do
          flags = bytes[offset..offset + 1].u2
          name = bytes[offset + 2..offset + 3].u2
          sig = bytes[offset + 4..offset + 5].u2
          offset += 6 # Skip the field header

          consumed, annotations = parse_attributes(bytes[offset..-1], constant_pool)
          fields << Java::Field.new(flags, constant_pool[name], constant_pool[sig], annotations.compact)
          offset += consumed
        end

        # Parse methods
        methods = Array.new
        methods_count = bytes[offset..offset + 1].u2
        offset += 2
        methods_count.times do
          flags = bytes[offset..offset + 1].u2
          name = bytes[offset + 2..offset + 3].u2
          sig = bytes[offset + 4..offset + 5].u2
          offset += 6

          consumed, annotations = parse_attributes(bytes[offset..-1], constant_pool)
          methods << Java::Method.new(flags, constant_pool[name], constant_pool[sig], annotations.compact)
          offset += consumed
        end

        # Parse class attributes
        _, annotations = parse_attributes(bytes[offset..-1], constant_pool)
        Java::Class.new(major, minor, access_flags, this_klass, super_klass, interfaces, fields, methods, annotations)
      end

      def to_double(fixnum)
        case fixnum
        when 0x7ff0000000000000 then Float::INFINITY
        when 0xfff0000000000000 then -Float::INFINITY
        #TODO: NaN
        else
          s = (fixnum >> 63) == 0 ? 1 : -1
          e = (fixnum >> 52) & 0x7ff
          m = e == 0 ? (fixnum & 0xfffffffffffff) << 1 : (fixnum & 0xfffffffffffff) | 0x10000000000000
          (s * m * 2**(e - 1075)).to_f
        end
      end

      def to_float(fixnum)
        case fixnum
        when 0x7f800000 then Float::INFINITY
        when 0xff800000 then Float::INFINITY
        #TODO: NaN
        else
          s = ((fixnum >> 31) == 0) ? 1 : -1
          e = ((fixnum >> 23) & 0xff)
          m = (e == 0) ?  (fixnum & 0x7fffff) << 1 : (fixnum & 0x7fffff) | 0x800000;
          (s * m * 2**(e - 150)).to_f
        end
      end

      def constant_pool_info_size(bytes)
        constant_pool_tag = bytes[0]
        case constant_pool_tag
        when CONSTANT_UTF8
          tag_content_size = bytes[1..2].u2
          val = bytes[3..tag_content_size + 2].modified_utf8_to_s
          return 3 + tag_content_size, val
        when CONSTANT_INTEGER
          val = bytes[1..4].u4
          return 5, val
        when CONSTANT_FLOAT
          val = to_float(bytes[1..4].u4)
          return 5, val
        when CONSTANT_LONG
          high_bytes = bytes[1..4].u4
          low_bytes = bytes[5..8].u4
          return 9, (high_bytes << 32) + low_bytes, constant_pool_tag
        when CONSTANT_DOUBLE
          high_bytes = bytes[1..4].u4
          low_bytes = bytes[5..8].u4
          return 9, to_double((high_bytes << 32) + low_bytes), constant_pool_tag
        when CONSTANT_STRING, CONSTANT_CLASS
          val = bytes[1..2].u2
          return 3, val
        when CONSTANT_FIELDREF, CONSTANT_METHODREF, CONSTANT_INTERFACEMETHODREF
          klass_index = bytes[1..2].u2
          name_and_type_index = bytes[3..4].u2
          return 5, [klass_index, name_and_type_index]
        when CONSTANT_NAMEANDTYPE
          name_index = bytes[1..2].u2
          descriptor_index = bytes[3..4].u2
          return 5, [name_index, descriptor_index]
        when CONSTANT_METHODHANDLE
          reference_kind = bytes[1].u1
          reference_index = bytes[2..3].u2
          return 4, [reference_kind, reference_index]
        when CONSTANT_METHODTYPE
          return 3, bytes[1..2].u2
        when CONSTANT_INVOKEDYNAMIC
          bootstrap_method_attr_index = bytes[1..2].u2
          name_and_type_index = bytes[3..4].u2
          return 5, [bootstrap_method_attr_index, name_and_type_index]
        else raise "Unknown Constant Pool Tag: 0x#{constant_pool_tag.to_s(16)}"
        end
      end

      def parse_annotation(bytes, constant_pool)
        annotations = {}
        num_annotations = bytes[0..1].u2
        offset = 2
        num_annotations.times do |_annotation|
          annotation_name_index = bytes[offset..offset + 1].u2
          num_value_pairs = bytes[offset + 2..offset + 3].u2
          offset += 4
          key_values = annotations[ constant_pool[annotation_name_index] ] = []
          num_value_pairs.times do |_value_pairs|
            name = bytes[offset..offset + 1].u2
            # TODO: Handle 4.7.16.1. The element_value structure
            value = bytes[offset + 3..offset + 4].u2
            key_values << constant_pool[name]
            key_values << constant_pool[value]
          end
        end
        return nil if annotations.empty?
        annotations
      end

      def parse_attributes(bytes, constant_pool)
        annotations = []
        attr_count = bytes[0..1].u2
        offset = 2 # Consume attr_count
        attr_count.times do |_attr|
          attr_name_index = bytes[offset..offset + 1].u2
          attr_size = bytes[offset + 2..offset + 5].u4
          offset += 6
          if (constant_pool[attr_name_index] == "RuntimeInvisibleAnnotations") && (attr_size > 0)
            annotations << parse_annotation(bytes[offset..offset + attr_size], constant_pool)
          end
          offset += attr_size
        end
        [offset, annotations]
      end
    end
  end
end
