class CreateDayUsePackagePassTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :day_use_package_pass_types do |t|
      t.references :day_use_schedule_pass_type, null: false, foreign_key: true, index: { name: :duspt_index }
      t.references :day_use_package, null: false, foreign_key: true

      t.timestamps
    end
  end
end
