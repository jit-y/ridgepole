describe 'Ridgepole::Client#diff -> migrate' do
  context 'when database and definition are same' do
    let(:dsl) {
      erbh(<<-EOS)
        create_table "clubs", <%= i cond(5.1, id: :serial) + {force: :cascade} %> do |t|
          t.string "name", limit: 255, default: "", null: false
        end

        <%= add_index "clubs", ["name"], name: "idx_name", unique: true, using: :btree %>

        create_table "departments", primary_key: "dept_no", id: :string, limit: 4, force: :cascade do |t|
          t.string "dept_name", limit: 40, null: false
        end

        <%= add_index "departments", ["dept_name"], name: "idx_dept_name", unique: true, using: :btree %>

        create_table "dept_emp", primary_key: ["emp_no", "dept_no"], force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "dept_no", limit: 4, null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_emp", ["dept_no"], name: "idx_dept_emp_dept_no", using: :btree %>
        <%= add_index "dept_emp", ["emp_no"], name: "idx_dept_emp_emp_no", using: :btree %>

        create_table "dept_manager", primary_key: ["emp_no", "dept_no"], force: :cascade do |t|
          t.string  "dept_no", limit: 4, null: false
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_manager", ["dept_no"], name: "idx_dept_manager_dept_no", using: :btree %>
        <%= add_index "dept_manager", ["emp_no"], name: "idx_dept_manager_emp_no", using: :btree %>

        create_table "employee_clubs", <%= i cond(5.1, id: :serial) + {force: :cascade} %> do |t|
          t.integer "emp_no", null: false
          t.integer "club_id", null: false
        end

        <%= add_index "employee_clubs", ["emp_no", "club_id"], name: "idx_employee_clubs_emp_no_club_id", using: :btree %>

        create_table "employees", primary_key: "emp_no", <%= i({id: :integer} + cond(5.1, default: nil) + {force: :cascade}) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", primary_key: ["emp_no", "from_date"], force: :cascade do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "salaries", ["emp_no"], name: "idx_salaries_emp_no", using: :btree %>

        create_table "titles", primary_key: ["emp_no", "title", "from_date"], force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "title", limit: 50, null: false
          t.date    "from_date", null: false
          t.date    "to_date"
        end

        <%= add_index "titles", ["emp_no"], name: "idx_titles_emp_no", using: :btree %>
      EOS
    }

    before { restore_tables }
    subject { client }

    it {
      delta = subject.diff(dsl)
      expect(delta.differ?).to be_falsey
      expect(subject.dump).to match_fuzzy dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy dsl
    }
  end
end
