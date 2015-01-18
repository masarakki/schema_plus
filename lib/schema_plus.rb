require 'active_record'
require 'valuable'

require 'schema_monkey'
require 'schema_db_default'
require 'schema_default_expr'
require 'schema_index_plus'
require 'schema_pg_enums'
require 'schema_views'

require 'schema_plus/version'
require 'schema_plus/active_record/base'
require 'schema_plus/active_record/column_options_handler'
require 'schema_plus/active_record/connection_adapters/abstract_adapter'
require 'schema_plus/active_record/connection_adapters/table_definition'
require 'schema_plus/active_record/connection_adapters/schema_statements'
require 'schema_plus/active_record/schema'
require 'schema_plus/active_record/connection_adapters/column'
require 'schema_plus/active_record/connection_adapters/foreign_key_definition'
require 'schema_plus/active_record/migration/command_recorder'
require 'schema_plus/middleware/dumper'
require 'schema_plus/middleware/migration'

module SchemaPlus
  module ActiveRecord

    module ConnectionAdapters
      autoload :MysqlAdapter, 'schema_plus/active_record/connection_adapters/mysql_adapter'
      autoload :PostgresqlAdapter, 'schema_plus/active_record/connection_adapters/postgresql_adapter'
      autoload :Sqlite3Adapter, 'schema_plus/active_record/connection_adapters/sqlite3_adapter'
    end
  end

  # This global configuation options for SchemaPlus.
  # Set them in +config/initializers/schema_plus.rb+ using:
  #
  #    SchemaPlus.setup do |config|
  #       ...
  #    end
  #
  # The options are grouped into subsets based on area of functionality.
  # See Config::ForeignKeys
  #
  class Config < Valuable

    # This set of configuration options control SchemaPlus's foreign key
    # constraint behavior.  Set them in
    # +config/initializers/schema_plus.rb+ using:
    #
    #    SchemaPlus.setup do |config|
    #       config.foreign_keys.auto_create = ...
    #    end
    #
    class ForeignKeys < Valuable
      ##
      # :attr_accessor: auto_create
      #
      # Whether to automatically create foreign key constraints for columns
      # suffixed with +_id+.  Boolean, default is +true+.
      has_value :auto_create, :klass => :boolean, :default => true

      ##
      # :attr_accessor: auto_index
      #
      # Whether to automatically create indexes when creating foreign key constraints for columns.
      # Boolean, default is +true+.
      has_value :auto_index, :klass => :boolean, :default => true

      ##
      # :attr_accessor: on_update
      #
      # The default value for +:on_update+ when creating foreign key
      # constraints for columns.  Valid values are as described in
      # ForeignKeyDefinition, or +nil+ to let the database connection use
      # its own default.  Default is +nil+.
      has_value :on_update

      ##
      # :attr_accessor: on_delete
      #
      # The default value for +:on_delete+ when creating foreign key
      # constraints for columns.  Valid values are as described in
      # ForeignKeyDefinition, or +nil+ to let the database connection use
      # its own default.  Default is +nil+.
      has_value :on_delete
    end
    has_value :foreign_keys, :klass => ForeignKeys, :default => ForeignKeys.new

    def dup #:nodoc:
      self.class.new(Hash[attributes.collect{ |key, val| [key, Valuable === val ?  val.class.new(val.attributes) : val] }])
    end

    def update_attributes(opts)#:nodoc:
      opts = opts.dup
      opts.keys.each { |key| self.send(key).update_attributes(opts.delete(key)) if self.class.attributes.include? key and Hash === opts[key] }
      super(opts)
      self
    end

    def merge(opts)#:nodoc:
      dup.update_attributes(opts)
    end

  end

  # Returns the global configuration, i.e., the singleton instance of Config
  def self.config
    @config ||= Config.new
  end

  # Initialization block is passed a global Config instance that can be
  # used to configure SchemaPlus behavior.  E.g., if you want to disable
  # automation creation of foreign key constraints for columns name *_id,
  # put the following in config/initializers/schema_plus.rb :
  #
  #    SchemaPlus.setup do |config|
  #       config.foreign_keys.auto_create = false
  #    end
  #
  def self.setup # :yields: config
    yield config
  end

  def self.insert #:nodoc:
    SchemaMonkey.include_once ::ActiveRecord::ConnectionAdapters::AbstractAdapter::SchemaCreation, SchemaPlus::ActiveRecord::ConnectionAdapters::AbstractAdapter::VisitTableDefinition
    SchemaMonkey.include_once ::ActiveRecord::ConnectionAdapters::AbstractAdapter, SchemaPlus::ActiveRecord::ColumnOptionsHandler
  end

end

SchemaMonkey.register(SchemaPlus)
