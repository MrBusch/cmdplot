# frozen_string_literal: true

require_relative 'test_helper'

class TablesTest < Minitest::Test
    include PlotHelpers

    Record = Struct.new(:attributes)

    ROWS = [{ 'id' => 1, 'name' => 'alpha' }, { 'id' => 22, 'name' => nil }].freeze

    def test_table
        expected = <<~TABLE
             id │  name
            ────┼───────
              1 │ alpha
             22 │      
        TABLE
        assert_equal expected, render { |p| p.table(ROWS) }
    end

    def test_table_fields_and_shorten
        expected = <<~TABLE
             nam │ id
            ─────┼────
             alp │  1
                 │ 22
        TABLE
        assert_equal expected, render { |p| p.table(ROWS, %w[name id], 3) }
    end

    def test_table_accepts_records
        records = [Record.new({ id: 7, name: 'r' })]
        assert_includes render { |p| p.table(records) }, '  7 │    r'
    end

    def test_empty_data_prints_nothing
        assert_equal '', render { |p| p.table([]) }
        assert_equal '', render { |p| p.expanded_table([]) }
        assert_equal '', render { |p| p.csv([]) }
    end

    def test_expanded_table
        expected = <<~TABLE
            ─[ RECORD 1 ]─┬────────────────────────────────────────────────────────
            id            │ 1
            name          │ alpha
            ─[ RECORD 2 ]─┬────────────────────────────────────────────────────────
            id            │ 22
            name          │ 
        TABLE
        assert_equal expected, render { |p| p.expanded_table(ROWS) }
    end

    def test_expanded_table_long_field_names
        text = render { |p| p.expanded_table([{ ('x' * 80) => 1 }]) }
        assert_includes text, "#{'x' * 80} │ 1"
    end

    def test_csv
        assert_equal "id, name\n1, alpha\n22, \n", render { |p| p.csv(ROWS) }
    end

    def test_csv_quotes_special_values
        text = render { |p| p.csv([{ 'a' => 'x, y', 'b' => 'say "hi"' }]) }
        assert_equal "a, b\n\"x, y\", \"say \"\"hi\"\"\"\n", text
    end
end
