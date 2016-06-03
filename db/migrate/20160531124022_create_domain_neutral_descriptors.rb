class CreateDomainNeutralDescriptors < ActiveRecord::Migration
  def change
    table_name = DomainNeutral::Descriptor.table_name
    create_table table_name, :force => true do |t|
      t.string   "type"
      t.string   "parent_type"
      t.integer  "parent_id"
      t.string   "symbol"
      t.string   "name"
      t.text     "description"
      t.integer  "index"
      t.integer  "value"
      t.timestamps null: false
    end

    add_index table_name, ["type", "symbol"],           name: "index_#{table_name}_on_type_and_symbol"
    add_index table_name, ["type", "index"],            name: "index_#{table_name}_on_type_and_index"
    add_index table_name, ["parent_type", "parent_id"], name: "index_#{table_name}_on_parent_type_and_parent_id"
  end
end
