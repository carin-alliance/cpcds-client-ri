class CreateDocumentReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :document_references do |t|

      t.timestamps
    end
  end
end
