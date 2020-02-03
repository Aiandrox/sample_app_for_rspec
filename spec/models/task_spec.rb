require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    it '全て入力されている場合 有効' do
      task = Task.new(title: 'タイトル', status: 'todo')
      expect(task).to be_valid
    end

    it 'タイトルが入力されていない場合 無効' do
      task = Task.new(title: '', status: 'todo')
      expect(task).to be_invalid
    end

    it 'タイトルが重複する場合 無効' do
      existing_task = create(:task)
      task = Task.new(title: 'タイトル', status: 'todo')
      expect(task).to be_invalid
    end

    it '違うタイトルの場合 有効' do
      existing_task = create(:task)
      task = Task.new(title: '違うタイトル', status: 'todo')
      expect(task).to be_valid
    end

    it 'ステータスが設定されていない場合 無効' do
      task = Task.new(title: 'タイトル', status: '')
      expect(task).to be_invalid
    end

    # it '設定以外のステータスの場合 無効' do
    #   task = Task.new(title: 'タイトル', status: 4)
    #   expect(task).to raise_error
    # end
  end
end
