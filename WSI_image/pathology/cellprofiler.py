# Setup environment
import cellprofiler_core.image
# import cellprofiler_core.object
# import cellprofiler_core.pipeline
import cellprofiler_core.preferences
import cellprofiler_core.workspace
cellprofiler_core.preferences.set_headless()

# Open a pipeline
pipeline = cellprofiler_core.pipeline.Pipeline()
pipeline.load("example.cppipe")

# Create ImageSetList and ImageSet instances
image_set_list = cellprofiler_core.image.ImageSetList()
image_set = image_set_list.get_image_set(0)

# Create Image instances, name and add them to the ImageSet instance
import skimage.data
x = skimage.data.camera()
image_x = cellprofiler_core.image.Image(x)
image_set.add("x", image_x)
skimage.io.imshow(image_set.get_image("x").pixel_data)

# Create an ObjectSet instance, name and add an Objects instance
object_set = cellprofiler_core.object.ObjectSet()
objects  = cellprofiler_core.object.Objects()
object_set.add_objects(objects, "example")

# Create a Measurements instance
measurements = cellprofiler_core.measurement.Measurements()

# Create a Workspace instance
workspace = cellprofiler_core.workspace.Workspace(
    pipeline,
    module,
    image_set,
    object_set,
    measurements,
    image_set_list,
)

# Run a pipeline
output_measurements = pipeline.run(None)