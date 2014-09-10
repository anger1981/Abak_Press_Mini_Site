class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :parent_id
      t.string :name
      t.string :title
      t.text :body
      t.string :reference

      t.timestamps
    end
  end
end
