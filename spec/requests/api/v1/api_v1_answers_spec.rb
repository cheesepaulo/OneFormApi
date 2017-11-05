require 'rails_helper'

RSpec.describe "Api::V1::Answers", type: :request do
  
  describe "GET /answers" do
    context "With Invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :get, "/api/v1/answers"
    end

    context "With Valid authentication headers" do
      before do
        @user = create(:user)
        @form = create(:form, user: @user)
        @answer1 = create(:answer, form: @form)
        @answer2 = create(:answer, form: @form)

        get "/api/v1/answers", params: {form_id: @form.id}, headers: header_with_authentication(@user)
      end

      it "returns 200" do
        expect_status(200)
      end

      it "returns Form list with 2 answers" do
        expect(json.count).to eql(2)
      end

      it "returned Answers have right datas" do
        expect(json[0]).to eql(JSON.parse(@answer1.to_json))
        expect(json[1]).to eql(JSON.parse(@answer2.to_json))
      end
    end
  end

  describe "GET /answers/:id" do
    
    context "With Invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :get, "/api/v1/answers/0"
    end

    context "With valid authentication headers" do
      before do
        @user = create(:user)
        @form = create(:form, user: @user)
      end

      context "When answer exists" do
        before do
          @answer = create(:answer, form: @form)
          @questions_answers_1 = create(:questions_answer, answer: @answer)
          @questions_answers_2 = create(:questions_answer, answer: @answer)          
          get "/api/v1/answers/#{@answer.id}", params: {}, headers: header_with_authentication(@user)
        end

        it "returns 200" do
          expect_status(200)
        end

        it "returned Answer with right datas" do
          expect(json.except("questions_answers")).to eql(JSON.parse(@answer.to_json))
        end

        it "returned associated questions_answers" do
          expect(json['questions_answers'][0]).to eql(JSON.parse(@questions_answers_1.to_json))
          expect(json['questions_answers'][1]).to  eql(JSON.parse(@questions_answers_2.to_json))
        end
      end

      context "When answer dont exists" do
        it "returns 404" do
          get "/api/v1/answers/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end

end
