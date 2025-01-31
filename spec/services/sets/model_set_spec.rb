# frozen_string_literal: true

require 'spec_helper'

describe Sets::ModelSet do
  describe "updating" do
    it "creates new models" do
      attrs = { collection_attributes: { '1' => { name: "Fantasia", iso_name: "FAN" },
                                         '2' => { name: "Utopia", iso_name: "UTO" } } }

      ms = Sets::ModelSet.new(Spree::Country,
                              Spree::Country.all,
                              attrs)

      expect { ms.save }.to change { Spree::Country.count }.by(2)

      expect(Spree::Country.where(name: ["Fantasia", "Utopia"]).count).to eq(2)
    end

    it "updates existing models" do
      e1 = create(:enterprise_group)
      e2 = create(:enterprise_group)

      attrs = { collection_attributes: { '1' => { id: e1.id, name: 'e1zz', description: 'foo' },
                                         '2' => { id: e2.id, name: 'e2yy', description: 'bar' } } }

      ms = Sets::ModelSet.new(EnterpriseGroup, EnterpriseGroup.all, attrs)

      expect { ms.save }.to change { EnterpriseGroup.count }.by(0)

      expect(EnterpriseGroup.where(name: ['e1zz', 'e2yy']).count).to eq(2)
    end

    it "destroys deleted models" do
      e1 = create(:enterprise)
      e2 = create(:enterprise)

      attributes = { collection_attributes: { '1' => { id: e1.id, name: 'deleteme' },
                                              '2' => { id: e2.id, name: 'e2' } } }

      ms = Sets::ModelSet.new(Enterprise, Enterprise.all, attributes, nil,
                              proc { |attrs| attrs['name'] == 'deleteme' })

      expect { ms.save }.to change { Enterprise.count }.by(-1)

      expect(Enterprise.where(id: e1.id)).to be_empty
      expect(Enterprise.where(id: e2.id)).to be_present
    end

    it "ignores deletable new records" do
      attributes = { collection_attributes: { '1' => { name: 'deleteme' } } }

      ms = Sets::ModelSet.new(Enterprise, Enterprise.all, attributes, nil,
                              proc { |attrs| attrs[:name] == 'deleteme' })

      expect { ms.save }.to change { Enterprise.count }.by(0)
    end

    describe "errors" do
      let(:product_b) { create(:simple_product, name: "Bananas") }
      let(:product_a) { create(:simple_product, name: "Apples") }
      let(:collection_attributes) do
        {
          0 => {
            id: product_a.id,
            name: "", # Product Name can't be blank
          },
          1 => {
            id: product_b.id,
            name: "Bananes",
          },
        }
      end
      subject{ Sets::ModelSet.new(Spree::Product, [product_a, product_b], collection_attributes:) }

      it 'errors are aggregated' do
        subject.save

        expect(subject.errors.full_messages).to eq ["Product Name can't be blank"]

        expect(subject.invalid).to     include product_a
        expect(subject.invalid).to_not include product_b
      end
    end
  end
end
