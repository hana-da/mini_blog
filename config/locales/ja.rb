# frozen_string_literal: true

{
  ja: { i18n: { plural: { keys: %i[zero one other], rule: lambda { |n|
                                                            case n
                                                            when 0; then :zero
                                                            when 1; then :one
                                                            else :other
                                                            end
                                                          } } } },
}
