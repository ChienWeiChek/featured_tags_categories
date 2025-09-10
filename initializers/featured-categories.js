import { apiInitializer } from 'discourse/lib/api';
import FeaturedCategories from '../components/featured-categories';

export default apiInitializer('1.14.0', (api) => {
  api.renderInOutlet(settings.plugin_outlet.trim(), FeaturedCategories);
});
