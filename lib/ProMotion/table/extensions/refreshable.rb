module ProMotion
  module Table
    module Refreshable

      def make_refreshable(params={})
        pull_message = params[:pull_message] || "Pull to refresh"
        @refreshing = params[:refreshing] || "Refreshing data..."
        @updated_format = params[:updated_format] || "Last updated at %s"
        @updated_time_format = params[:updated_time_format] || "%l:%M %p"
        @refreshable_callback = params[:callback] || :on_refresh

        @text_attributes = params[:text_attributes] || {}
        @tint_color = params[:tint_color] || UIColor.lightGrayColor

        @refresh_control = UIRefreshControl.alloc.init
        @refresh_control.attributedTitle = create_refresh_attributed_string(pull_message)
        @refresh_control.tintColor = @tint_color
        @refresh_control.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
        self.refreshControl = @refresh_control
      end

      def start_refreshing
        return unless @refresh_control

        @refresh_control.beginRefreshing

        # Scrolls the table down to show the refresh control when invoked programatically
        tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y-@refresh_control.frame.size.height), animated:true) if tableView.contentOffset.y > -65.0
      end
      alias :begin_refreshing :start_refreshing

      def end_refreshing
        return unless @refresh_control

        @refresh_control.attributedTitle = create_refresh_attributed_string(sprintf(@updated_format, Time.now.strftime(@updated_time_format)))
        @refresh_control.endRefreshing
      end
      alias :stop_refreshing :end_refreshing

      ######### iOS methods, headless camel case #######

      # UIRefreshControl Delegates
      def refreshView(refresh)
        refresh.attributedTitle = create_refresh_attributed_string(@refreshing)
        if @refreshable_callback && self.respond_to?(@refreshable_callback)
          self.send(@refreshable_callback)
        else
          PM.logger.warn "You must implement the '#{@refreshable_callback}' method in your TableScreen."
        end
      end

      private

      def create_refresh_attributed_string(text)
        NSAttributedString.alloc.initWithString(text, attributes: @text_attributes)
      end

    end
  end
end
