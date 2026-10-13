#include <gtest/gtest.h>
#include "math_utils.h"

TEST(MathTest, BasicAddition)
{
    EXPECT_EQ(add(2, 3), 5);
}
