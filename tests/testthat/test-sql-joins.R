context("SQL: joins")

src <- src_sqlite(tempfile(), create = TRUE)
df1 <- copy_to(src, data.frame(x = 1:5, y = 1:5), "df1")
df2 <- copy_to(src, data.frame(a = 5:1, b = 1:5), "df2")
fam <- copy_to(src, data.frame(id = 1:5, parent = c(NA, 1, 2, 2, 4)), "fam")

test_that("named by join by different x and y vars", {

  j1 <- collect(inner_join(df1, df2, c("x" = "a")))
  expect_equal(names(j1), c("x", "y", "a", "b"))
  expect_equal(nrow(j1), 5)

  j2 <- collect(inner_join(df1, df2, c("x" = "a", "y" = "b")))
  expect_equal(names(j2), c("x", "y", "a", "b"))
  expect_equal(nrow(j2), 1)
})

test_that("self-joins allowed with named by", {
  j1 <- collect(left_join(fam, fam, by = c("parent" = "id")))
  j2 <- collect(inner_join(fam, fam, by = c("parent" = "id")))

  expect_equal(names(j1), c("id.x", "parent.x", "id.y", "parent.y"))
  expect_equal(names(j2), c("id.x", "parent.x", "id.y", "parent.y"))
  expect_equal(nrow(j1), 5)
  expect_equal(nrow(j2), 4)

  j3 <- collect(semi_join(fam, fam, by = c("parent" = "id")))
  j4 <- collect(anti_join(fam, fam, by = c("parent" = "id")))

  expect_equal(j3, filter(collect(fam), !is.na(parent)))
  expect_equal(j4, filter(collect(fam), is.na(parent)))
})
