#include <fdeep/fdeep.hpp>
int main()
{
    const auto model = fdeep::load_model("sql_injection.json");
    const auto result = model.predict({
            fdeep::tensor(fdeep::tensor_shape(static_cast<std::size_t>(5)),std::vector<float>{0, 1, 0, 1, 0})
        });
    std::cout << fdeep::show_tensors(result) << std::endl;
}