require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    let(:new_task) { Task.new(title: title, status: status) }
    let(:title) { 'タイトル' }
    let(:status) { :todo }
    let(:task) { create(:task) }

    it '全て入力されている場合 有効' do
      expect(task).to be_valid
    end

    context 'タイトルが入力されていない場合' do
      let(:title) { '' }
      it '無効' do
        expect(new_task).to be_invalid
      end
    end

    it 'タイトルが重複する場合 無効' do
      task
      expect(new_task).to be_invalid
    end

    context 'タイトルが重複しない場合' do
      let(:title) { '違うタイトル' }
      it '無効' do
        task
        expect(new_task).to be_valid
      end
    end

    context 'ステータスが空白の場合' do
      let(:status) { '' }
      it '無効' do
        expect(new_task).to be_invalid
      end
    end

    # context '設定されていないステータスを入力した場合' do
    #   let(:status) { 'not_set' }
    #   it '無効' do
    #     expect(new_task).to be_invalid
    #   end
    # end
  end
end
