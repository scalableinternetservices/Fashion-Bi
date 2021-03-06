class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: [:feed, :wardrobe]

  # home page
  def home
  end

  # old fb login page
  def login
  end

  # user home page
  def feed
    #@photos = Photo.where(user_id: current_user.email)


    @photos = Array.new # for storing the photos for feed
    @stored_recs = OutfitRec.where(user_id: current_user.email)
    if @stored_recs.empty?
      print "have to generate new recs"
      @shirts = Photo.where("user_id = ? AND category = \'shirt\'", current_user.email).to_a.shuffle
      @jackets = Photo.where("user_id = ? AND category = \'jacket\'", current_user.email).to_a.shuffle
      @pants = Photo.where("user_id = ? AND category = \'pants\'", current_user.email).to_a.shuffle
      @shoes = Photo.where("user_id = ? AND category = \'shoes\'", current_user.email).to_a.shuffle

      @sz_shirts = @shirts.size
      @sz_jackets = @jackets.size
      @sz_pants = @pants.size
      @sz_shoes = @shoes.size

      @sz_min = @sz_shirts
      if @sz_min > @sz_jackets
        @sz_min = @sz_jackets
      end
      if @sz_min > @sz_pants
        @sz_min = @sz_pants
      end
      if @sz_min > @sz_shoes
        @sz_min = @sz_shoes
      end

      @it = 0
      while @it < @sz_min do
        @c_shirt = @shirts.last
        @shirt_color = @c_shirt.color

        # pant color should be different from shirt color if possible
        @c_pant = nil
        @pants.each do |pant|
          if pant.color != @c_shirt.color
            @c_pant = pant
            break
          end
        end
        #@c_pant = @pants.where("color <> ?", @shirt_color).first
        if @c_pant.nil?
          @c_pant = @pants.last
        end
        @pant_color = @c_pant.color

        # jacket color should be different from shirt and pant color if possible
        @c_jacket = nil
        @jackets.each do |jacket|
          if jacket.color != @c_shirt.color and jacket.color != @c_pant.color
            @c_jacket = jacket
            break
          end
        end
        #@c_jacket = @jackets.where("color <> ? AND color <> ?", @shirt_color, @pant_color).first
        if @c_jacket.nil?
          @c_jacket = @jackets.last
        end

        @c_shoes = nil
        @shoes.each do |shoe|
          if shoe.color == @c_shirt.color
            @c_shoes = shoe
            break
          end
        end
        #@c_shoes = @shoes.where("color = ?", @shirt_color).first
        if @c_shoes.nil?
          @c_shoes = @shoes.last
        end

        # @shirts = @shirts.where("id <> ?", @c_shirt.id)
        # @jackets = @jackets.where("id <> ?", @c_jacket.id)
        # @pants = @pants.where("id <> ?", @c_pant.id)
        # @shoes = @shoes.where("id <> ?", @c_shoes.id)
        @shirts.delete(@c_shirt)
        @pants.delete(@c_pant)
        @jackets.delete(@c_jacket)
        @shoes.delete(@c_shoes)

        @outfit_rec = OutfitRec.new

        @outfit_rec.user_id = current_user.email

        @outfit_rec.clothes_ids = "#{@c_shirt.id} #{@c_jacket.id} #{@c_pant.id} #{@c_shoes.id}"

        @outfit_rec.date = DateTime.now

        @outfit_rec.save

        @photos.push(@c_shirt.image)
        @photos.push(@c_jacket.image)
        @photos.push(@c_pant.image)
        @photos.push(@c_shoes.image)
        @photos.push(@outfit_rec.id)
        @photos.push(@outfit_rec.user_id)

        @it = @it+1
      end
    else
      print "have storec recs; use those"
      if stale?(@stored_recs, public: true)
          @stored_recs.each do |rec|
            # rec.delete
            @c_ids = rec.clothes_ids.split(" ").map { |s| s.to_i }
            @c_ids.each do |c_id|
              @c_photo = Photo.where(id: c_id)
              @photos.push(@c_photo.first.image)
            end
            @photos.push(rec.id)
            @photos.push(rec.user_id)
          end
      end
    end

  end

  # user wardrobe
  def wardrobe
  end

end
