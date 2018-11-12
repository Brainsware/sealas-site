var gulp  = require('gulp');

var clean = require('gulp-clean');

var sass = require('gulp-sass');

var less = require('gulp-less');
var path = require('path');

var cssmin = require('gulp-cssmin');
// Alternative Minify
// var minifyCSS = require('gulp-minify-css');
var rename = require('gulp-rename');

var taskListing = require('gulp-task-listing');


gulp.task('clean', function () {
  return gulp.src('css', {read: false})
    .pipe(clean());
});

gulp.task('minify', function () {
  gulp.src('css/raleway.css')
    .pipe(cssmin())
    .pipe(rename({suffix: '.min'}))
    .pipe(gulp.dest('./css'));
});

gulp.task('build-sass', (['clean']), function () {
  gulp.src('scss/raleway.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./css'));
});

gulp.task('build-less', (['clean']), function () {
  return gulp.src('less/raleway.less')
    .pipe(less({
      paths: [ path.join(__dirname, 'less', 'includes') ]
    }))
    .pipe(gulp.dest('./css'));
});

// Help tasks
gulp.task('help', taskListing);

