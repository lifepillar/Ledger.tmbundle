require 'bigdecimal'

class Posting

  attr :account
  attr :commodity
  attr :note
  attr_accessor :amount

  # Initializes a posting.
  def initialize(account, amount, commodity, note)
    @account = account
    @amount = BigDecimal.new(amount)
    @commodity = commodity
    @note = note
  end

  # Returns true if this is a virtual posting, return false otherwise.
  def virtual?
    @account =~ /^[(\[]/ ? true : false
  end

  # Returns the index of the best candidate to balance this posting among the given list of postings.
  # Returns nil if no matching posting can be found (this may happen if the commodity
  # of this posting and the commodities of the other postings differ or if all the other
  # postings use the same account as this posting or if they are all zero).
  def best_match postings
    i = postings.find_index { |a| a.account != self.account and a.amount == -self.amount and a.commodity == self.commodity }
    i = postings.find_index { |a| a.account != self.account and a.amount.abs > self.amount.abs and a.amount.sign != self.amount.sign and a.commodity == self.commodity } if i.nil?
    i = postings.find_index { |a| a.account != self.account and a.amount.nonzero? and a.amount.sign != self.amount.sign and a.commodity == self.commodity } if i.nil?
    i = postings.find_index { |a| a.account != self.account and a.amount.nonzero? and a.commodity == self.commodity } if i.nil?
    return i
  end

  def to_s
    s = @account + '  ' + @amount.to_s('F') + ' ' + @commodity
    s << '  ; ' + @note unless @note.empty?
    return s
  end

end # class Posting

class SingleEntry

  class << self
    attr_accessor :keep_top_level_accounts
    attr_accessor :account_separator
    attr_accessor :category_separator
    attr_accessor :display_account_separator
    attr_accessor :display_category_separator
  end

  attr :date
  attr :code
  attr :payee
  attr :account
  attr :display_account
  attr :category
  attr :display_category
  attr :amount
  attr :display_amount
  attr :commodity
  attr :status
  attr :note

  def initialize date, status, code, payee, account, category, amount, commodity, note
    @date = date
    @code = code
    @payee = payee
    @account = account
    if SingleEntry.keep_top_level_accounts
      @display_account = @account
    else
      @display_account = @account.split(SingleEntry.account_separator)
      @display_account.shift
      @display_account = @display_account.join(SingleEntry.display_account_separator)
      @display_account = @account if @display_account.empty?
    end
    @category = category
    if SingleEntry.keep_top_level_accounts
      @display_category = @category
    else
      @display_category = @category.split(SingleEntry.category_separator)
      @display_category.shift
      @display_category = @display_category.join(SingleEntry.display_category_separator)
      @display_category = @category if @display_category.empty?
    end
    @amount = amount
    @display_amount = @amount.to_s('F')
    @commodity = commodity
    @status = status
    @note = note
  end

  def size
    9
  end

  def [](idx)
    case idx
    when 0
      @date
    when 1
      @status
    when 2
      @code
    when 3
      @payee
    when 4
      @display_account
    when 5
      @display_category
    when 6
      @display_amount
    when 7
      @commodity
    when 8
      @note
    else
      raise "Index out of bounds"
    end
  end
  def to_a
    [@date, @status, @code, @payee, @display_account, @display_category, @display_amount, @commodity, @note]
  end

end # class SingleEntry

class Transaction

  class << self
    attr_accessor :real_accounts_regexp
    attr_accessor :swap_sign
  end

  attr :date
  attr :code
  attr :payee
  attr :status

  def initialize opts = {}
    @date     = opts[:date]
    @code     = opts[:code]   || ''
    @payee    = opts[:payee]  || ''
    @status   = opts[:status] || ''
    @neg_cat  = []
    @pos_cat  = []
    @real_acc = []
    @single_entries = nil
    @sign = Transaction.swap_sign ? -1 : 1
  end

  def add posting
    if posting.account =~ Transaction.real_accounts_regexp
      @real_acc << posting
    elsif posting.amount.sign == BigDecimal::SIGN_NEGATIVE_FINITE
      @neg_cat << posting
    else
      @pos_cat << posting
    end
  end

  def postings
    @pos_cat + @neg_cat + @real_acc
  end

  def empty?
    @pos_cat.empty? and @neg_cat.empty? and @real_acc.empty?
  end

  # Returns true if this transaction is balanced (the amounts sum to zero);
  # returns false otherwise.
  def balanced?
    sum = BigDecimal('0.0')
    self.postings.each { |p| sum += p.amount }
    return sum.zero?
  end

  # Returns a “single-entry” version of this transaction, as an array of SingleEntry objects.
  def to_single_entry
    return @single_entries unless @single_entries.nil?
    return [] if @real_acc.empty?
    @single_entries = []

    (@neg_cat+@pos_cat).each do |c|
      while c.amount.nonzero?
        i = c.best_match(@real_acc)
        break if i.nil? # no match, skip current posting
        amount = move(@real_acc[i], c)
        @single_entries << single_entry(@real_acc[i], c.account, amount, c.note)
      end
    end

    # Transfers between real accounts
    @real_acc.each do |c|
      while c.amount.nonzero?
        i = c.best_match(@real_acc)
        break if i.nil? # no match, skip current posting
        amount = move(@real_acc[i], c)
        @single_entries << single_entry(@real_acc[i], 'Transfer', amount, "Transfer to #{c.account}")
        @single_entries << single_entry(c, 'Transfer', -amount, "Transfer from #{@real_acc[i].account}")
      end
    end
    [@neg_cat, @pos_cat, @real_acc].each do |a|
      a.delete_if { |p| p.amount.zero? }
    end
    return @single_entries
  end

  def to_s
    s = @date + ' ' + @status
    s << ' (' << @code << ')' unless @code.empty?
    s << ' ' << @payee << "\n"
    self.postings.each { |p| s << '  ' << p.to_s << "\n" }
    return s
  end

  private

  def move from, to
    if from.amount.sign != to.amount.sign
      amount = (from.amount.abs >= to.amount.abs) ? to.amount : -from.amount
    else
      amount = to.amount
    end
    from.amount += amount
    to.amount -= amount
    return amount
  end

  def single_entry real_account, category, amount, note
    SingleEntry.new(@date, @status, @code, @payee,
      real_account.account, category, @sign * amount, real_account.commodity, note)
  end

end # class Transaction

# Set defaults
SingleEntry.keep_top_level_accounts = true
SingleEntry.account_separator = ':'
SingleEntry.category_separator = ':'
SingleEntry.display_account_separator = ':'
SingleEntry.display_category_separator = ':'
Transaction.real_accounts_regexp = /^asset|^liabilities:credit card/i
Transaction.swap_sign = false
