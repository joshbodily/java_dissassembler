module Java
  class Field < Annotatable
    attr_reader :flags, :name, :vm_type, :java_type, :annotations

    ACC_PUBLIC    = 0x0001 # Declared public; may be accessed from outside its package.
    ACC_PRIVATE   = 0x0002 # Declared private; usable only within the defining class.
    ACC_PROTECTED = 0x0004 # Declared protected; may be accessed within subclasses.
    ACC_STATIC    = 0x0008 # Declared static.
    ACC_FINAL     = 0x0010 # Declared final; never directly assigned to after object construction (JLS §17.5).
    ACC_VOLATILE  = 0x0040 # Declared volatile; cannot be cached.
    ACC_TRANSIENT = 0x0080 # Declared transient; not written or read by a persistent object manager.
    ACC_SYNTHETIC = 0x1000 # Declared synthetic; not present in the source code.
    ACC_ENUM      = 0x4000 # Declared as an element of an enum.

    def initialize(flags, name, vm_type, annotations)
      super(annotations)
      @flags = flags
      @name = name
      @vm_type = vm_type
    end

    def is_public?
      (@flags & ACC_PUBLIC) != 0
    end

    def is_private?
      (@flags & ACC_PRIVATE) != 0
    end

    def is_protected?
      (@flags & ACC_PROTECTED) != 0
    end

    def is_static?
      (@flags & ACC_STATIC) != 0
    end

    def is_final?
      (@flags & ACC_FINAL) != 0
    end

    def is_volatile?
      (@flags & ACC_VOLATILE) != 0
    end

    def is_transient?
      (@flags & ACC_TRANSIENT) != 0
    end

    def is_synthetic?
      (@flags & ACC_SYNTHETIC) != 0
    end

    def is_enum?
      (@flags & ACC_ENUM) != 0
    end
  end
end
