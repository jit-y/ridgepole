describe 'Ridgepole::Client#diff -> migrate' do
  subject { client }

  context 'when add_index contains expression' do
    let(:actual_dsl) { '' }
    let(:expected_dsl) { erbh(<<-EOS) }
      create_table "users", force: :cascade do |t|
        t.string "name", null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index "lower((name)::text)", <%= i({name: "index_users_on_lower_name"} + cond(5.0, using: :btree)) %>
      end
    EOS

    specify do
      delta = subject.diff(expected_dsl)
      expect(delta).to be_differ
      expect(subject.dump).to match_fuzzy(actual_dsl)
      delta.migrate
      expect(subject.dump).to match_fuzzy(expected_dsl)
    end
  end
end
