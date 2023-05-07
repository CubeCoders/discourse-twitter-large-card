# name: discourse-twitter-large-card
# about: Makes sure that posts use the summary_large_image Twitter embed type for more engaging posts.
# version: 0.1
# author: Michael Biggins, Terrapop
# url: https://github.com/CubeCoders/discourse-twitter-large-card
# transpile_js: true

after_initialize do
 reloadable_patch do |plugin|
  ApplicationHelper.module_eval do

    def crawlable_meta_data(opts = nil)
        opts ||= {}
        opts[:url] ||= "#{Discourse.base_url_no_prefix}#{request.fullpath}"

        if opts[:image].blank?
          twitter_summary_large_image_url = SiteSetting.site_twitter_summary_large_image_url

          if twitter_summary_large_image_url.present?
            opts[:twitter_summary_large_image] = twitter_summary_large_image_url
          end

          opts[:image] = SiteSetting.site_opengraph_image_url
        end

        # With and height available?

        # Use the correct scheme for opengraph/twitter image
        opts[:image] = get_absolute_image_url(opts[:image]) if opts[:image].present?
        opts[:twitter_summary_large_image] =
          get_absolute_image_url(opts[:twitter_summary_large_image]) if opts[:twitter_summary_large_image].present?

        # Add opengraph & twitter tags
        result = []
        result << tag(:meta, property: 'og:site_name', content: SiteSetting.title)

        if opts[:twitter_summary_large_image].present?
          result << tag(:meta, name: 'twitter:card', content: "summary_large_image")
          result << tag(:meta, name: "twitter:image", content: opts[:twitter_summary_large_image])
        elsif opts[:image].present?
          result << tag(:meta, name: 'twitter:card', content: "summary_large_image")
          result << tag(:meta, name: "twitter:image", content: opts[:image])
        else
          result << tag(:meta, name: 'twitter:card', content: "summary")
        end
        result << tag(:meta, property: "og:image", content: opts[:image]) if opts[:image].present?

        [:url, :title, :description].each do |property|
          if opts[property].present?
            content = (property == :url ? opts[property] : gsub_emoji_to_unicode(opts[property]))
            result << tag(:meta, { property: "og:#{property}", content: content }, nil, true)
            result << tag(:meta, { name: "twitter:#{property}", content: content }, nil, true)
          end
        end

        if opts[:read_time] && opts[:read_time] > 0 && opts[:like_count] && opts[:like_count] > 0
          result << tag(:meta, name: 'twitter:label1', value: I18n.t("reading_time"))
          result << tag(:meta, name: 'twitter:data1', value: "#{opts[:read_time]} mins 🕑")
          result << tag(:meta, name: 'twitter:label2', value: I18n.t("likes"))
          result << tag(:meta, name: 'twitter:data2', value: "#{opts[:like_count]} ❤")
        end

        if opts[:published_time]
          result << tag(:meta, property: 'article:published_time', content: opts[:published_time])
        end

        if opts[:ignore_canonical]
          result << tag(:meta, property: 'og:ignore_canonical', content: true)
        end

        result.join("\n")
      end

  end
 end
end
