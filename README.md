
> ## This is the README for SchemaPlus 2.0.0 (prelease)
> which is under development in the master branch, and which supports Rails >= 4.2.  For info about the stable 1.x releases which support Rails 3.1, 4.0, 4.1, and 4.2, see the [schema_plus 1.x](https://github.com/SchemaPlus/schema_plus/tree/1.x) branch

---

[![Gem Version](https://badge.fury.io/rb/schema_plus.svg)](http://badge.fury.io/rb/schema_plus)
[![Build Status](https://secure.travis-ci.org/SchemaPlus/schema_plus.svg)](http://travis-ci.org/SchemaPlus/schema_plus)
[![Coverage Status](https://img.shields.io/coveralls/SchemaPlus/schema_plus.svg)](https://coveralls.io/r/SchemaPlus/schema_plus)
[![Dependency Status](https://gemnasium.com/lomba/schema_plus.svg)](https://gemnasium.com/SchemaPlus/schema_plus)

# SchemaPlus 2.x

Starting with version 2.0.0, schema_plus is a wrapper that pulls in a collection of individual feature gems:

* [schema_plus_indexes](https://github.com/SchemaPlus/schema_plus_indexes) -- Convenience and consistency in defining and manipulting indexes
* [schema_plus_pg_indexes](https://github.com/SchemaPlus/schema_plus_pg_indexes) -- Support for PostgreSQL index features: `case_insenstive`, `expression` and `operator_class`

See detailed documentation in each feature gem's README.  You can of course just use whichever of those gems you want individually, rather than this wrapper.

> **IN PROGRESS:** In the prerelease versions of SchemaPlus 2.0, more feature gems have yet to be stripped out, and the code is still in the body of schema_plus.  Anticipated features gems include:
> 
> * schema_plus_columns -- Extra Column features, including `column.indexes` and `column.unique?`
> * schema_plus_db_default -- Supports `update_attributes!(my_attr: ActiveRecord::DB_DEFAULT)` to set a column back to the default in the database schema. 
> * schema_plus_default_expr -- Supports using SQL expressions for database default values
> * schema_plus_enums -- Support for enum types
> * schema_plus_foreign_keys -- Extends support for foreign keys, including automatic creation.
> * schema_plus_tables -- Convenience and consistency in defining and manipulating tables
> * schema_plus_views -- Adds support for creating and manipulating views
>
> The documentation for these features is at the end of this README


## Upgrading from SchemaPlus 1.8.x

SchemaPlus 2.0.x intends to be completely backwards-compatible with SchemaPlus 1.8.x (though SchemaPlus 2.0.x only supports rails >= 4.2)

### Deprecations
In cases where rails 4.2 has introduced features previously supported only by SchemaPlus, but using different names, SchemaPlus 2.0 now issues deprecation warnings in favor of the rails form.  The complete list of deprecations:

* Index definitions deprecate these options:
  * `:conditions` => `:where`
  * `:kind` => `:using`

* Foreign key definitions deprecate options to `:on_update` and `:on_delete`:
  * `:set_null` => `:nullify`

* `add_foreign_key` and `remove_foreign_key` deprecate the method signature:
  * `(from_table, columns, to_table, primary_keys, options)` => `(from_table, to_table, options)`

* `ForeignKeyDefinition` deprecates accessors: 
  * `#table_name` in favor of `#from_table`
  * `#column_names` in favor of `#column`
  * `#references_column_names` in favor of `#primary_key`
  * `#references_table_name in favor of `#to_table`

* `IndexDefinition` deprecates accessors: 
  * `#conditions` in favor of `#where`
  * `#kind` in favor of `#using`

### Incompatibility

The only known backwards-incompatibility is that `IndexDefinition#kind`, now deprecated to `IndexDefinition#using`, now returns a symbol rather than a string.


## Compatibility

SchemaPlus 2.x is tested against all combinations of:

<!-- SCHEMA_DEV: MATRIX - begin -->

## Installation

Install from http://rubygems.org via

    $ gem install "schema_plus"

or in a Gemfile

    gem "schema_plus"
    
## History

*   See [CHANGELOG](CHANGELOG.md) for per-version release notes.

*   SchemaPlus is derived from several "Red Hill On Rails" plugins originally
    created by [@harukizaemon](https://github.com/harukizaemon)

*   SchemaPlus was created in 2011 by [@mlomnicki](https://github.com/mlomnicki) and [@ronen](https://github.com/ronen)

*   And [lots of contributors](https://github.com/SchemaPlus/schema_plus/graphs/contributors) since then

## Development & Testing

Are you interested in contributing to schema_plus?  Thanks!

Schema_plus has a full set of rspec tests.  [travis-ci](http://travis-ci.org/SchemaPlus/schema_plus) runs the tests on the full matrix of supported versions of ruby, rails, and db adapters.  But you can also test all or some part of the matrix locally before you push your changes, using

    $ schema_dev rspec


For more details, see the [schema_dev](https://github.com/SchemaPlus/schema_dev) README.

---    
---

# Prerelease:  Documentation of features still be moved into separate feature gems

    
> **NOTE** The documentation in this README is leftover from the 1.x branch; the functionality is the same, but some of the core features of schema_plus (such as foreign keys & inline index definition) are now provided by ActiveRecord 4.2.  schema_plus still provides extra functionality beyond AR 4.2, but the documentation needs to be updated to be clear what's an enhancement of AR 4.2 capabilities rather than completely new features.

### Columns


When you query column information using ActiveRecord::Base#columns, SchemaPlus
analogously provides index information relevant to each column: which indexes
reference the column, whether the column must be unique, etc.  See doc for
[SchemaPlus::ActiveRecord::ConnectionAdapters::Column](http://rubydoc.info/gems/schema_plus/SchemaPlus/ActiveRecord/ConnectionAdapters/Column).

### Foreign Key Constraints

SchemaPlus adds support for foreign key constraints. In fact, for the common
convention that you name a column with suffix `_id` to indicate that it's a
foreign key, SchemaPlus automatically defines the appropriate constraint.

SchemaPlus also creates foreign key constraints for rails' `t.references` or
`t.belongs_to`, which take the singular of the referenced table name and
implicitly create the column suffixed with `_id`.

You can explicitly specify whether or not to generate a foreign key
constraint, and specify or override automatic options, using the
`:foreign_key` keyword

Here are some examples:

    t.integer :author_id                              # automatically references table 'authors', key id
    t.integer :parent_id                              # special name parent_id automatically references its own table (for tree nodes)
    t.integer :author_id, foreign_key: true           # same as default automatic behavior
    t.integer :author,    foreign_key: true           # non-conventional column name needs to force creation, table name is assumed to be 'authors'
    t.integer :author_id, foreign_key: false          # don't create a constraint

    t.integer :author_id, foreign_key: { references: :authors }        # same as automatic behavior
    t.integer :author,    foreign_key: { reference: :authors}          # same default name
    t.integer :author_id, foreign_key: { references: [:authors, :id] } # same as automatic behavior
    t.integer :author_id, foreign_key: { references: :people }         # override table name
    t.integer :author_id, foreign_key: { references: [:people, :ssn] } # override table name and key
    t.integer :author_id, foreign_key: { references: nil }             # don't create a constraint
    t.integer :author_id, foreign_key: { name: "my_fk" }               # override default generated constraint name
    t.integer :author_id, foreign_key: { on_delete: :cascade }
    t.integer :author_id, foreign_key: { on_update: :set_null }
    t.integer :author_id, foreign_key: { deferrable: true }
    t.integer :author_id, foreign_key: { deferrable: :initially_deferred }

Of course the options can be combined, e.g.

    t.integer :author_id, foreign_key: { name: "my_fk", on_delete: :no_action }

As a shorthand, all options except `:name` can be specified without placing
them in a hash, e.g.

    t.integer :author_id, on_delete: :cascade
    t.integer :author_id, references: nil

The foreign key behavior can be configured globally (see Config) or per-table
(see create_table).

To examine your foreign key constraints, `connection.foreign_keys` returns a
list of foreign key constraints defined for a given table, and
`connection.reverse_foreign_keys` returns a list of foreign key constraints
that reference a given table.  See doc at
[SchemaPlus::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition](http://rubydoc.info/gems/schema_plus/SchemaPlus/ActiveRecord/ConnectionAdapters/ForeignKeyDefinition).

#### Foreign Key Issues

Foreign keys can cause issues for Rails utilities that delete or load data
because referential integrity imposes a sequencing requirement that those
utilities may not take into consideration.  Monkey-patching may be required
to address some of these issues.  The Wiki article [Making yaml_db work with
foreign key constraints in PostgreSQL](https://github.com/SchemaPlus/schema_plus/wiki/Making-yaml_db-work-with-foreign-key-constraints-in-PostgreSQL)
has some information that may be of assistance in resolving these issues.

### Tables

SchemaPlus extends rails' `drop_table` method to accept these options:

    drop_table :table_name                    # same as rails
    drop_table :table_name, if_exists: true   # no error if table doesn't exist
    drop_table :table_name, cascade: true     # delete dependencies

The `:cascade` option is particularly useful given foreign key constraints.
For Postgresql it is implemented using `DROP TABLE...CASCADE` which deletes
all dependencies.  For MySQL, SchemaPlus implements the `:cascade` option to
delete foreign key references, but does not delete any other dependencies.
For Sqlite3, the `:cascade` option is ignored, but Sqlite3 always drops tables
with cascade-like behavior.

SchemaPlus likewise extends `create_table ... force: true` to use `:cascade`

### Views

SchemaPlus provides support for creating and dropping views.  In a migration,
a view can be created using a rails relation or literal sql:

    create_view :posts_commented_by_staff,  Post.joins(comment: user).where(users: {role: 'staff'}).uniq
    create_view :uncommented_posts,        "SELECT * FROM posts LEFT OUTER JOIN comments ON comments.post_id = posts.id WHERE comments.id IS NULL"

And can be dropped:

    drop_view :posts_commented_by_staff
    drop_view :uncommented_posts, :if_exists => true

ActiveRecord works with views the same as with ordinary tables.  That is, for
the above views you can define

    class PostCommentedByStaff < ActiveRecord::Base
      table_name = "posts_commented_by_staff"
    end

    class UncommentedPost < ActiveRecord::Base
    end

Note: In PostgreSQL, all internal views (the ones with `pg_` prefix) will be skipped.

### Column Defaults: Expressions

SchemaPlus allows defaults to be set using expressions or constant values:

    t.datetime :seen_at, default: { expr: 'NOW()' }
    t.datetime :seen_at, default: { value: "2011-12-11 00:00:00" }

Note that in MySQL only the TIMESTAMP column data type accepts SQL column
defaults and Rails uses DATETIME, so expressions can't be used with MySQL.

The standard syntax will still work as usual:

    t.datetime :seen_at, default: "2011-12-11 00:00:00"

Also, as a convenience

    t.datetime :seen_at, default: :now

resolves to:

    NOW()                 # PostgreSQL
    (DATETIME('now'))     # SQLite3
    invalid               # MySQL

If you are using Postgresql with a `json` column, the default value may be an unadorned hash.  A hash having just one key `:expr` or `:value` will be taken as schema_plus syntax; i.e, these two are equivalent:

	t.json :fields, default: { field1: 'a', field2: 'b' }
	t.json :fields, default: { value: { field1: 'a', field2: 'b' } }
	

### Column Defaults: Using

SchemaPlus introduces a constant `ActiveRecord::DB_DEFAULT` that you can use
to explicitly instruct the database to use the column default value (or
expression).  For example:

    Post.create(category: ActiveRecord::DB_DEFAULT)
    post.update_attributes(category: ActiveRecord::DB_DEFAULT)

(Without `ActiveRecord::DB_DEFAULT`, you can update a value to `NULL` but not
to its default value.)

Note that after updating, you would need to reload a record to replace
`ActiveRecord::DB_DEFAULT` with the value assigned by the database.

Note also that Sqlite3 does not support `ActiveRecord::DB_DEFAULT`; attempting
to use it will raise `ActiveRecord::StatementInvalid`

### Enums (PostgreSQL only)

SchemaPlus provides support for creating, altering and dropping enums. In a migration,
a enum can be created:

    create_enum :color, :red, :green, :blue # default schema is 'public'
    create_enum :cmyk, :cyan, :magenta, :yellow, :black, :schema => 'color'

And can be altered: (added a new value)

    alter_enum :color, :black
    alter_enum :color, :purple, :after => 'red'
    alter_enum :color, :pink, :before => 'purple'
    alter_enum :color, :white, :schema => 'public'

Finally, a enum can be dropped:

    drop_enum :color
    drop_enum :cmyk, :schema => 'color'

### Schema Dump and Load (schema.rb)

When dumping `schema.rb`, SchemaPlus orders the views and tables in the schema
dump alphabetically, but subject to the requirement that each table or view be
defined before those that depend on it.  This allows all foreign key
constraints to be defined within the scope of the table definition. (Unless
there are cyclical dependencies, in which case some foreign keys constraints
must be defined later.)

Also, when dumping `schema.rb`, SchemaPlus dumps explicit foreign key
definition statements rather than relying on the auto-creation behavior, for
maximum clarity and for independence from global config.  And correspondingly,
when loading a schema, i.e. with the context of `ActiveRecord::Schema.define`,
SchemaPlus ensures that auto creation of foreign key constraints is turned off
regardless of the global setting.  But if for some reason you are creating
your schema.rb file by hand, and would like to take advantage of auto-creation
of foreign key constraints, you can re-enable it:

    ActiveRecord::Schema.define do
        SchemaPlus.config.foreign_keys.auto_create = true
        SchemaPlus.config.foreign_keys.auto_index = true

        create_table ...etc...
    end


