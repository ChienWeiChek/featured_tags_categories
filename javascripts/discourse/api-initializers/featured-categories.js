import FeaturedCategories from '../components/featured-categories';
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.renderInOutlet(settings.plugin_outlet.trim(), FeaturedCategories);
});
