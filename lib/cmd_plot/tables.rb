# frozen_string_literal: true

class CmdPlot
    # Tabular dumps of records.
    #
    # data is an array of hashes, or of objects that respond to #attributes (e.g. an
    # ActiveRecord relation). Objects are turned into hashes with string keys and string
    # values, so pass field names as strings for them.
    module Tables
        # Columns separated by │, each as wide as its longest value.
        #
        # fields  - keys to show, in order (default: the keys of the first record)
        # shorten - cut every column to at most this many characters
        def table(data, fields = nil, shorten = nil)
            rows = records(data)
            fields ||= rows.first&.keys
            return nil if fields.nil?

            widths = fields.map { |f|
                width = ([f.to_s.length] + rows.map { |r| r[f].to_s.length }).max
                shorten.nil? ? width : [width, shorten].min
            }
            cut = ->(value) { shorten.nil? ? value.to_s : value.to_s[0, shorten] }
            line = ->(values) { " #{values.zip(widths).map { |v, w| cut.call(v).rjust(w) }.join(' │ ')}" }

            buf = +''
            buf << line.call(fields) << "\n"
            buf << widths.map { |w| '─' * (w + 2) }.join('┼') << "\n"
            rows.each { |r| buf << line.call(fields.map { |f| r[f] }) << "\n" }
            out.print(buf)
            nil
        end

        # One block per record with a line per field, like psql's \x mode. Useful when
        # records have too many fields for a table.
        def expanded_table(data, fields = nil)
            rows = records(data)
            fields ||= rows.first&.keys
            return nil if fields.nil?

            num_width = rows.length.to_s.length
            name_width = [13 + num_width, fields.map { |f| f.to_s.length }.max + 1].max
            buf = +''
            rows.each_with_index { |r, i|
                buf << "─[ RECORD #{(i + 1).to_s.rjust(num_width)} ]─" << ('─' * (name_width - 13 - num_width))
                buf << '┬' << ('─' * [70 - name_width, 0].max) << "\n"
                fields.each { |f| buf << f.to_s.ljust(name_width) << '│ ' << r[f].to_s << "\n" }
            }
            out.print(buf)
            nil
        end

        # Comma-separated values with a header line. Values that contain a comma, quote or
        # line break are quoted.
        def csv(data, fields = nil)
            rows = records(data)
            fields ||= rows.first&.keys
            return nil if fields.nil?

            buf = +''
            buf << fields.map { |f| csv_value(f) }.join(', ') << "\n"
            rows.each { |r| buf << fields.map { |f| csv_value(r[f]) }.join(', ') << "\n" }
            out.print(buf)
            nil
        end

        private

        def records(data)
            data.map { |row|
                if row.respond_to?(:attributes)
                    row.attributes.to_h { |k, v| [k.to_s, v.to_s] }
                else
                    row
                end
            }
        end

        def csv_value(value)
            text = value.to_s
            return text unless text.match?(/[",\r\n]/)

            "\"#{text.gsub('"', '""')}\""
        end
    end

    include Tables
end
